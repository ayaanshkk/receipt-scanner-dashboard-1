import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_scanner/screens/results_list.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'results_screen.dart';

// Configurable server URL
const String serverUrl = 'http://192.168.0.66:3000/ocr'; // For Android emulator

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
        print('Camera initialization error: $e');
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
      print('Error capturing image: $e');
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

      print('Setting focus at screen point: (${point.dx}, ${point.dy})');
      print('Normalized coordinates: ($x, $y)');

      await _controller!.setFocusMode(FocusMode.locked);
      await Future.delayed(Duration(milliseconds: 50));
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      setState(() {
        _focusPoint = point;
        _showFocusIndicator = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showFocusIndicator = false;
          });
        }
      });

      print('Focus successfully set at normalized coordinates: ($x, $y)');
    } catch (e) {
      print('Focus error: $e');
      try {
        await _controller!.setFocusMode(FocusMode.auto);
        print('Fallback to auto focus mode');
      } catch (fallbackError) {
        print('Fallback focus error: $fallbackError');
      }
    }
  }

  Future<void> _sendImageAndNavigate() async {
    if (_capturedImageFile == null) return;

    try {
      final inputImage = InputImage.fromFilePath(_capturedImageFile!.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final String rawText = recognizedText.text;
      print('OCR Text: $rawText');

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': rawText}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out. Check server at $serverUrl');
        },
      );

      print('Server Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final String responseBody = response.body;

        if (!mounted) return;

        final ReceiptEntry? result = await Navigator.push<ReceiptEntry>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              data: responseBody,
              imageFile: _capturedImageFile!,
            ),
          ),
        );

        if (result != null && widget.onEntryAdded != null) {
          widget.onEntryAdded!(result);
          if (mounted) Navigator.pop(context);
        }
      } else {
        print('Server error: ${response.statusCode}. Using local OCR parsing.');
        String total = '0.00';
        String? date;
        String? merchant;
        for (var block in recognizedText.blocks) {
          final text = block.text.toLowerCase();
          if (text.contains('total') || text.contains('amount')) {
            final lines = block.text.split('\n');
            for (var line in lines) {
              final match = RegExp(r'(?:£|\$|€)?\s*(\d+\.\d{2})').firstMatch(line);
              if (match != null) {
                total = match.group(1) ?? '0.00';
                break;
              }
            }
          }
          if (merchant == null && block.text.isNotEmpty) {
            merchant = block.text.split('\n').first;
          }
          final dateMatch = RegExp(r'\d{1,2}/\d{1,2}/\d{2,4}|\d{4}-\d{2}-\d{2}').firstMatch(block.text);
          if (dateMatch != null) {
            date = dateMatch.group(0);
          }
        }

        final result = ReceiptEntry(
          imageFile: _capturedImageFile!,
          merchant: merchant ?? 'Unknown Store',
          currency: '£',
          total: total,
          category: 'General',
          date: date != null ? DateTime.tryParse(date) ?? DateTime.now() : DateTime.now(),
        );

        if (!mounted) return;

        final confirmedResult = await Navigator.push<ReceiptEntry>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              data: jsonEncode({
                'establishment': merchant ?? 'Unknown Store',
                'total': total,
                'currency': '£',
                'category': 'General',
                'date': date ?? DateTime.now().toIso8601String(),
                'VAT': null,
                'method_of_payment': null,
              }),
              imageFile: _capturedImageFile!,
            ),
          ),
        );

        if (confirmedResult != null && widget.onEntryAdded != null) {
          widget.onEntryAdded!(confirmedResult);
          if (mounted) Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error processing receipt: $e');
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
      print('Error picking image: $e');
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
                      onTapDown: (details) {
                        _setFocusPoint(details.localPosition);
                      },
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
    final iconColor = isDark ? Colors.white : Colors.black;

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