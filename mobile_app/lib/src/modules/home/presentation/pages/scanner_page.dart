import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/src/modules/home/presentation/pages/scan_result_page.dart';
import 'package:path_provider/path_provider.dart';


import 'package:mobile_app/services/ocr_service.dart';
import '../../../../core/theme/app_colors.dart' as theme;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  bool _ready = false;
  bool _processing = false;
  int _cameraIndex = 0;
  FlashMode _flash = FlashMode.off;

  Offset? _tapPosition;
  bool _showFocusCircle = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras![_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flash);

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }


  void _handleTapFocus(TapUpDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;


    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = details.localPosition;
    final double fullWidth = box.size.width;
    final double fullHeight = box.size.height;


    final double x = localPos.dx / fullWidth;
    final double y = localPos.dy / fullHeight;

    setState(() {
      _tapPosition = localPos;
      _showFocusCircle = true;
    });

    try {
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));
    } catch (e) {
      debugPrint("Lỗi lấy nét: $e");
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showFocusCircle = false);
    });
  }


  Future<File> _cropToFrame(XFile file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return File(file.path);


    image = img.bakeOrientation(image);

    final int w = image.width;
    final int h = image.height;


    final int cropW = (w * 0.8).toInt();
    final int cropH = (h * 0.18).toInt();

    final int left = (w - cropW) ~/ 2;
    final int top = (h - cropH) ~/ 2;

    final img.Image cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: cropW,
      height: cropH,
    );

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(img.encodeJpg(cropped));
  }

  Future<void> _scan() async {
    if (_processing || _controller == null || !_controller!.value.isInitialized) return;

    setState(() => _processing = true);

    try {
      final raw = await _controller!.takePicture();
      final cropped = await _cropToFrame(raw);
      
      final text = await OCRService.recognizeTextFromImage(cropped);

      if (!mounted) return;


      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanResultPage(text: text)),
      );
    } catch (e) {
      debugPrint("Lỗi khi scan: $e");
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _processing = true);
    try {
      final text = await OCRService.recognizeTextFromImage(File(file.path));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ScanResultPage(text: text)),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _switchCamera() {
    _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
    _controller?.dispose();
    _ready = false;
    _initCamera();
  }

  void _toggleFlash() async {
    _flash = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller?.setFlashMode(_flash);
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: theme.AppColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),


          Positioned.fill(
            child: GestureDetector(onTapUp: _handleTapFocus),
          ),


          if (_showFocusCircle && _tapPosition != null)
            Positioned(
              left: _tapPosition!.dx - 35,
              top: _tapPosition!.dy - 35,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.AppColors.accent, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            ),


          const IgnorePointer(child: _ScannerOverlay()),


          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _flash == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
            ),
          ),


          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Action(icon: Icons.photo, label: "ALBUM", onTap: _pickGallery),
                GestureDetector(
                  onTap: _scan,
                  child: _processing
                      ? const CircularProgressIndicator(color: theme.AppColors.accent)
                      : const _ScanBtn(),
                ),
                _Action(icon: Icons.flip_camera_ios, label: "XOAY", onTap: _switchCamera),
              ],
            ),
          ),
          

          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ReticlePainter(),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.AppColors.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;


    final w = size.width * 0.8;
    final h = size.height * 0.18; 
    final l = (size.width - w) / 2;
    final t = (size.height - h) / 2;

    final rect = Rect.fromLTWH(l, t, w, h);
    

    canvas.drawRect(rect, paint);
    

    final cornerPaint = Paint()
      ..color = theme.AppColors.accent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    
    final double cLen = 20.0;

    canvas.drawLine(Offset(l, t), Offset(l + cLen, t), cornerPaint);
    canvas.drawLine(Offset(l, t), Offset(l, t + cLen), cornerPaint);

    canvas.drawLine(Offset(l + w, t), Offset(l + w - cLen, t), cornerPaint);
    canvas.drawLine(Offset(l + w, t), Offset(l + w, t + cLen), cornerPaint);

    canvas.drawLine(Offset(l, t + h), Offset(l + cLen, t + h), cornerPaint);
    canvas.drawLine(Offset(l, t + h), Offset(l, t + h - cLen), cornerPaint);

    canvas.drawLine(Offset(l + w, t + h), Offset(l + w - cLen, t + h), cornerPaint);
    canvas.drawLine(Offset(l + w, t + h), Offset(l + w, t + h - cLen), cornerPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ScanBtn extends StatelessWidget {
  const _ScanBtn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        gradient: const LinearGradient(
          colors: [theme.AppColors.accent, Colors.orangeAccent],
        ),
      ),
      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
    );
  }
}