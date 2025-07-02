import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_scanner/screens/results_list.dart';
import 'package:receipt_scanner/screens/results_screen.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:receipt_scanner/secure_storage.dart';

class ScanReceiptPage extends StatefulWidget {
  final List cameras;
  final Function(ReceiptEntry)? onEntryAdded;

  const ScanReceiptPage({required this.cameras, this.onEntryAdded, super.key});

  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  CameraController? _controller;
  bool _isFlashOn = false;
  File? _capturedImageFile;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future _initializeCamera() async {
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
      try {
        await _controller!.initialize();
        await _controller!.setFlashMode(FlashMode.off);
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);
        if (mounted) setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future _toggleFlash() async {
    if (_controller != null) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    }
  }

  Future _captureImage() async {
    if (_controller == null) return;
    try {
      final image = await _controller!.takePicture();
      _capturedImageFile = File(image.path);
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future _setFocusPoint(Offset point) async {
    if (_controller == null || !_controller!.value.isInitialized || _capturedImageFile != null) {
      return;
    }
    try {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final double x = (point.dx / size.width).clamp(0.0, 1.0);
      final double y = (point.dy / size.height).clamp(0.0, 1.0);

      await _controller!.setFocusMode(FocusMode.locked);
      await Future.delayed(const Duration(milliseconds: 50));
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      setState(() {
        _focusPoint = point;
        _showFocusIndicator = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showFocusIndicator = false);
      });
    } catch (e) {
      try {
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (_) {}
    }
  }

  Future<void> _sendImageAndNavigate() async {
    if (_capturedImageFile == null) return;

    final token = await SecureStorage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }

    try {
      final inputImage = InputImage.fromFilePath(_capturedImageFile!.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final String rawText = recognizedText.text;

      final response = await http.post(
        Uri.parse('https://receipt-scanner-backend-0d53818d62b3.herokuapp.com/api/receipts/process-receipt'), // Replace with actual URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': rawText}),
      );

      if (response.statusCode == 200) {
        final result = await Navigator.push<ReceiptEntry>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              data: response.body,
              imageFile: _capturedImageFile!,
            ),
          ),
        );

        if (result != null && widget.onEntryAdded != null && mounted) {
          widget.onEntryAdded!(result);
          Navigator.pop(context);
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Processing failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _discardImage() {
    _capturedImageFile = null;
    if (mounted) setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _capturedImageFile = File(pickedFile.path);
        if (mounted) setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan Receipt', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1C1C1E),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _capturedImageFile != null
              ? Positioned.fill(child: Image.file(_capturedImageFile!, fit: BoxFit.cover))
              : Stack(
                  children: [
                    GestureDetector(
                      onTapDown: (details) => _setFocusPoint(details.localPosition),
                      child: CameraPreview(_controller!),
                    ),
                    if (_showFocusIndicator && _focusPoint != null)
                      Positioned(
                        left: _focusPoint!.dx - 30,
                        top: _focusPoint!.dy - 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.yellow, width: 3),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.yellow, width: 1),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _capturedImageFile == null ? _buildCameraControls() : _buildPreviewControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1D1F) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(color: backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: iconColor,
              size: 30,
            ),
            onPressed: _toggleFlash,
          ),
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white : Colors.black, width: 4),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.photo_library,
              color: iconColor,
              size: 30,
            ),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewControls() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1D1F) : Colors.white;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(color: backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _discardImage,
            child: _circleButton(icon: Icons.close, isDark: isDark, iconColor: Colors.red),
          ),
          GestureDetector(
            onTap: _sendImageAndNavigate,
            child: _circleButton(icon: Icons.check, isDark: isDark, iconColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required bool isDark, required Color iconColor}) {
    final buttonColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: buttonColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Icon(icon, color: iconColor, size: 35),
    );
  }
}