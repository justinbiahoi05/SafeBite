import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:ui';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Camera error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),

        Positioned.fill(child: _ScannerOverlayPainter()),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          child: Center(
            child: _GlassLabel(
              text: 'Detecting ingredients...',
              isPulsing: true,
            ),
          ),
        ),

        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircularAction(
                  icon: Icons.photo_library_outlined,
                  label: 'GALLERY',
                ),
                _MainScanButton(),
                _CircularAction(
                  icon: Icons.flip_camera_ios_outlined,
                  label: 'FLIP',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

    final double width = size.width * 0.75; // Slightly wider for better framing
    final double height = width * 1.2;
    final double left = (size.width - width) / 2;
    final double top =
        (size.height - height) / 2 -
        60; // Shifting up to be visually centered above buttons
    final double cornerLen = 30.0;

    // Top Left Corner
    canvas.drawLine(Offset(left, top + cornerLen), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLen, top), paint);

    // Top Right Corner
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

    // Bottom Left Corner
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

    // Bottom Right Corner
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

class _GlassLabel extends StatelessWidget {
  final String text;
  final bool isPulsing;
  final Color? color;
  final Color? textColor;

  const _GlassLabel({
    required this.text,
    this.isPulsing = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.15),
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
                  color: textColor ?? Colors.white.withValues(alpha: 0.9),
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

class _CircularAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CircularAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _MainScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: const Icon(
          Icons.document_scanner_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
