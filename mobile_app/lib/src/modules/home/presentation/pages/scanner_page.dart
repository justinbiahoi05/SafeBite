import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import 'package:mobile_app/services/ai_service.dart';
import 'package:mobile_app/services/scan_history_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  int _currentCameraIndex = 0;

  // Scanning state
  final _ingredientsController = TextEditingController();
  final _productNameController = TextEditingController();
  final _aiService = AIService();
  bool _isScanning = false;
  bool _isAiReady = false;
  ScanResult? _lastResult;
  bool _showResult = false;
  bool _isCameraActive = true; // Track camera state

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initAI();
  }

  Future<void> _initAI() async {
    await _aiService.initAI();
    if (mounted) {
      setState(() => _isAiReady = true);
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      debugPrint('No cameras available');
      return;
    }
    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _controller?.dispose();

    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera flip error: $e');
    }
  }

  Future<String?> _captureAndUploadImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    try {
      // Capture image
      final XFile image = await _controller!.takePicture();

      // Get reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('scans')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload file
      final file = File(image.path);
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await storageRef.putFile(file, metadata);

      // Get download URL
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Failed to capture image: $e');
      return null;
    }
  }

  Future<void> _scanIngredients() async {
    final text = _ingredientsController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter ingredients first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _showResult = false;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get real prediction with confidence from ML model
    final prediction = _aiService.predict(text);
    final result = prediction["label"];
    final confidence = prediction["confidence"];

    // Determine if safe or needs caution
    final isSafe = result == 'safe';

    if (mounted) {
      setState(() {
        _isScanning = false;
        _lastResult = ScanResult(
          result: result,
          confidence: confidence,
          ingredients: text,
          isSafe: isSafe,
        );
        _showResult = true;
      });
      // Pause camera when showing results
      _pauseCamera();
    }
  }

  Future<void> _saveScanWithProductName() async {
    if (_lastResult == null) return;

    // Show product name input dialog
    final productName = await _showProductNameDialog();
    if (productName == null) return; // User cancelled

    // Capture and upload image (optional, don't fail scan if it fails)
    String? imageUrl;
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        imageUrl = await _captureAndUploadImage();
      }
    } catch (e) {
      debugPrint('Image capture skipped: $e');
      imageUrl = null;
    }

    // Save to history with product name
    try {
      await ScanHistoryService().addScan(
        result: _lastResult!.result,
        confidence: _lastResult!.confidence,
        ingredients: _lastResult!.ingredients.split(',').map((e) => e.trim()).toList(),
        imageUrl: imageUrl,
        productName: productName,
      );
    } catch (e) {
      debugPrint('Failed to save scan: $e');
    }

    // Update the result with product name and show success
    if (mounted) {
      setState(() {
        _lastResult = ScanResult(
          result: _lastResult!.result,
          confidence: _lastResult!.confidence,
          ingredients: _lastResult!.ingredients,
          isSafe: _lastResult!.isSafe,
          productName: productName,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<String?> _showProductNameDialog() async {
    _productNameController.clear();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the product name (optional)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _productNameController,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'e.g., Coca-Cola, Snickers',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _productNameController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Scan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _resetScanner() {
    // Resume camera when going back to scanner
    _resumeCamera();
    setState(() {
      _showResult = false;
      _lastResult = null;
      _ingredientsController.clear();
    });
  }

  Future<void> _resumeCamera() async {
    if (_controller != null && !_controller!.value.isInitialized) {
      await _initializeCamera();
    }
    _isCameraActive = true;
  }

  void _pauseCamera() {
    _isCameraActive = false;
    // Dispose camera to release image buffers
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _resumeCameraPreview() async {
    // Reinitialize camera
    await _initializeCamera();
    _isCameraActive = true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ingredientsController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult && _lastResult != null) {
      return _ResultView(
        result: _lastResult!,
        onScanAgain: _resetScanner,
        onAddMore: _resetScanner,
        onSave: _saveScanWithProductName,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_cameras == null || _cameras!.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No camera available',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          else if (_isCameraInitialized && _controller != null && _isCameraActive)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),

          // Overlay
          Positioned.fill(child: _ScannerOverlayPainter()),

          // Status Label
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: _GlassLabel(
                text: _isScanning ? 'Analyzing...' : 'Ready to scan',
                isPulsing: _isScanning,
              ),
            ),
          ),

          // Input Field
          Positioned(
            bottom: 220,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  hintText: 'Enter ingredients (e.g., water, sugar, salt)',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: _ingredientsController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _ingredientsController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _scanIngredients(),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'GALLERY',
                    onTap: () => _showTextInputDialog(),
                  ),
                  _ScanButton(
                    isScanning: _isScanning,
                    onTap: _scanIngredients,
                  ),
                  _ActionButton(
                    icon: Icons.flip_camera_ios_outlined,
                    label: 'FLIP',
                    onTap: _cameras != null && _cameras!.length > 1
                        ? _flipCamera
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextInputDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Ingredients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type ingredients separated by commas',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ingredientsController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Water, Sugar, Salt, Citric Acid',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _scanIngredients();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Analyze',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Result View
class ScanResult {
  final String result;
  final double confidence;
  final String ingredients;
  final bool isSafe;
  final String? productName;

  ScanResult({
    required this.result,
    required this.confidence,
    required this.ingredients,
    required this.isSafe,
    this.productName,
  });
}

class _ResultView extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onScanAgain;
  final VoidCallback onAddMore;
  final VoidCallback onSave;

  const _ResultView({
    required this.result,
    required this.onScanAgain,
    required this.onAddMore,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: onScanAgain,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: result.isSafe
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.isSafe ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: result.isSafe ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          result.isSafe ? 'SAFE' : 'CAUTION',
                          style: TextStyle(
                            color: result.isSafe ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: result.isSafe
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: result.isSafe
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      result.isSafe
                          ? Icons.eco_rounded
                          : Icons.warning_amber_rounded,
                      size: 64,
                      color: result.isSafe ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.result.toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: result.isSafe ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ingredients
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCANNED INGREDIENTS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.ingredients,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Product Name (if available)
              if (result.productName != null && result.productName!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRODUCT NAME',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.productName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAddMore,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Scan More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSave, // Save scan with product name
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Scanner Overlay Painter
class _ScannerOverlayPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ReticlePainter());
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width * 0.75;
    final double height = width * 1.2;
    final double left = (size.width - width) / 2;
    final double top = (size.height - height) / 2 - 100;
    final double cornerLen = 30.0;

    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), paint);

    canvas.drawLine(
      Offset(left + width - cornerLen, top),
      Offset(left + width, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + width, top),
      Offset(left + width, top + cornerLen),
      paint,
    );

    canvas.drawLine(
      Offset(left, top + height - cornerLen),
      Offset(left, top + height),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + height),
      Offset(left + cornerLen, top + height),
      paint,
    );

    canvas.drawLine(
      Offset(left + width - cornerLen, top + height),
      Offset(left + width, top + height),
      paint,
    );
    canvas.drawLine(
      Offset(left + width, top + height),
      Offset(left + width, top + height - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Glass Label Widget
class _GlassLabel extends StatelessWidget {
  final String text;
  final bool isPulsing;

  const _GlassLabel({required this.text, this.isPulsing = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPulsing)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Scan Button
class _ScanButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onTap;

  const _ScanButton({required this.isScanning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onTap,
      child: Container(
        width: 88,
        height: 88,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.buttonGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent,
                blurRadius: 15,
                spreadRadius: -5,
              ),
            ],
          ),
          child: isScanning
              ? const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : const Icon(
                  Icons.document_scanner_rounded,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
    );
  }
}