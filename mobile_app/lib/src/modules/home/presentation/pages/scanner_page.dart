import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mobile_app/services/ai_service.dart';
import 'package:mobile_app/services/scan_history_service.dart';
import 'package:mobile_app/services/ocr_service.dart';
import '../../../../core/theme/app_colors.dart';

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
  FlashMode _flashMode = FlashMode.off;

  // Scanning state
  final _ingredientsController = TextEditingController();
  final _productNameController = TextEditingController();
  final _aiService = AIService();
  
  bool _isScanning = false;
  bool _isAiReady = false;
  ScanResult? _lastResult;
  bool _showResult = false;
  bool _isCameraActive = true;

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
    if (_cameras == null || _cameras!.isEmpty) return;

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

  void _toggleFlash() async {
    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller?.setFlashMode(_flashMode);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _controller?.dispose();
    _isCameraInitialized = false;
    _initializeCamera();
  }

  // Chọn ảnh từ Gallery và quét chữ (OCR)
  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isScanning = true);
    try {
      final text = await OCRService.recognizeTextFromImage(File(file.path));
      if (text.isNotEmpty) {
        _ingredientsController.text = text;
        _scanIngredients(); 
      }
    } catch (e) {
      debugPrint("OCR Error: $e");
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _scanIngredients() async {
    final text = _ingredientsController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isScanning = true;
      _showResult = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    final prediction = _aiService.predict(text);
    
    if (mounted) {
      setState(() {
        _isScanning = false;
        _lastResult = ScanResult(
          result: prediction["label"],
          confidence: prediction["confidence"],
          ingredients: text,
          isSafe: prediction["label"] == 'safe',
        );
        _showResult = true;
      });
      _pauseCamera();
    }
  }

  void _pauseCamera() {
    _isCameraActive = false;
    _controller?.dispose();
    _controller = null;
  }

  void _resetScanner() {
    _initializeCamera().then((_) {
      setState(() {
        _isCameraActive = true;
        _showResult = false;
        _lastResult = null;
        _ingredientsController.clear();
      });
    });
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
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized && _controller != null && _isCameraActive)
            Positioned.fill(child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),

          Positioned.fill(child: _ScannerOverlay()),

          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(_flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on, color: Colors.white),
              onPressed: _toggleFlash,
            ),
          ),

          Positioned(
            bottom: 220,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _ingredientsController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Nhập hoặc quét thành phần...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _scanIngredients(),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(icon: Icons.photo_library, label: 'ALBUM', onTap: _pickGallery),
                _ScanButton(isScanning: _isScanning, onTap: _scanIngredients),
                _ActionButton(icon: Icons.flip_camera_ios, label: 'XOAY', onTap: _flipCamera),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Các Widget hỗ trợ ---

class ScanResult {
  final String result;
  final double confidence;
  final String ingredients;
  final bool isSafe;
  ScanResult({required this.result, required this.confidence, required this.ingredients, required this.isSafe});
}

class _ResultView extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onScanAgain;
  final VoidCallback onAddMore;

  const _ResultView({required this.result, required this.onScanAgain, required this.onAddMore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(result.isSafe ? Icons.check_circle : Icons.warning, 
                 color: result.isSafe ? Colors.green : Colors.orange, size: 100),
            const SizedBox(height: 20),
            Text(result.result.toUpperCase(), 
                 style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Độ tin cậy: ${(result.confidence * 100).toStringAsFixed(1)}%", 
                 style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: onScanAgain, child: const Text("QUÉT LẠI")),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _ReticlePainter());
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.accent..style = PaintingStyle.stroke..strokeWidth = 3;
    final w = size.width * 0.8;
    final h = size.height * 0.2;
    final rect = Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2 - 50, w, h);
    canvas.drawRect(rect, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onTap;
  const _ScanButton({required this.isScanning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onTap,
      child: Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: AppColors.buttonGradient)),
        child: isScanning 
          ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white))
          : const Icon(Icons.document_scanner, color: Colors.white, size: 40),
      ),
    );
  }
}