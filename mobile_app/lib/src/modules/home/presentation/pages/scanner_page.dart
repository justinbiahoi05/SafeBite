import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_result_page.dart';
import '../../../../../services/groq_service.dart';
import '../../../../core/theme/app_colors.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isProcessing = false;
  bool _isFlashOn = false;

  final ImagePicker _picker = ImagePicker();
  File? _capturedImageFile;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _setCamera(_selectedCameraIndex);
    }
  }

  Future<void> _setCamera(int index) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    _controller = CameraController(
      _cameras![index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (mounted) setState(() {});
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    _isFlashOn = false;
    _setCamera(_selectedCameraIndex);
  }

  Future<void> _pickFromGallery() async {
    if (_isFlashOn) {
      _isFlashOn = false;
      await _controller?.setFlashMode(FlashMode.off);
      setState(() {});
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && !_isProcessing) {
      setState(() => _isProcessing = true);
      _processImage(File(image.path));
    }
  }

  Future<void> _captureAndScan() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final XFile? image = await _controller?.takePicture();

      if (_isFlashOn) {
        _isFlashOn = false;
        await _controller?.setFlashMode(FlashMode.off);
        setState(() {});
      }

      if (image != null) await _processImage(File(image.path));
    } catch (e) {
      _showError("Failed to capture image.");
      setState(() => _isProcessing = false);
    }
  }

  bool _hasNavigated = false;

  Future<void> _processImage(File imageFile) async {
    // Guard: prevent multiple calls
    if (_hasNavigated || !_isProcessing) return;
    _hasNavigated = true;

    setState(() {
      _capturedImageFile = imageFile;
    });
    try {
      final resultJson = await GroqService.extractIngredients(
        XFile(imageFile.path),
      );

      if (resultJson != null && resultJson.isNotEmpty) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultPage(
              rawText: "",
              initialGroqData: resultJson,
              capturedImageFile: imageFile,
            ),
          ),
        ).then((_) {
          _hasNavigated = false;
          setState(() => _isProcessing = false);
        });
      } else {
        _showError(
          "AI could not read the label. Please try again with a clearer photo.",
        );
        _hasNavigated = false;
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      _showError("Error: $e");
      _hasNavigated = false;
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade800),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_controller!)),

          Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: AppColors.primaryGreen,
                overlayColor: Colors.black.withOpacity(0.6),
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.yellow : Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        _isFlashOn = !_isFlashOn;
                        _controller?.setFlashMode(
                          _isFlashOn ? FlashMode.torch : FlashMode.off,
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Scan ingredients list",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: _pickFromGallery,
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _captureAndScan,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProcessing
                                  ? Colors.grey
                                  : AppColors.primaryGreen,
                            ),
                            child: _isProcessing
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 80),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final Color overlayColor;
  const _ScannerOverlayShape({
    required this.borderColor,
    required this.overlayColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final holeRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2 - 20),
      width: width * 0.9,
      height: height * 0.5,
    );

    final path = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = overlayColor);

    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect, const Radius.circular(20)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
