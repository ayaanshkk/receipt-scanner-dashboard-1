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
        // Set focus mode to auto initially
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
      // Get screen dimensions
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      
      // Convert screen coordinates to normalized coordinates [0.0, 1.0]
      final double x = (point.dx / size.width).clamp(0.0, 1.0);
      final double y = (point.dy / size.height).clamp(0.0, 1.0);

      print('Setting focus at screen point: (${point.dx}, ${point.dy})');
      print('Normalized coordinates: ($x, $y)');

      // Set focus mode to locked to ensure we can control focus manually
      await _controller!.setFocusMode(FocusMode.locked);
      
      // Small delay to ensure mode change takes effect
      await Future.delayed(Duration(milliseconds: 50));
      
      // Set the focus point
      await _controller!.setFocusPoint(Offset(x, y));
      
      // Also set exposure point for better results
      await _controller!.setExposurePoint(Offset(x, y));

      // Show focus indicator
      setState(() {
        _focusPoint = point;
        _showFocusIndicator = true;
      });

      // Hide focus indicator after 2 seconds
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
      // If manual focus fails, fallback to auto focus
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
      // Step 1: Perform on-device OCR
      final inputImage = InputImage.fromFilePath(_capturedImageFile!.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final String rawText = recognizedText.text;
      print('OCR Text: $rawText'); // Log OCR output for debugging

      // Step 2: Send the extracted text to the backend server
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': rawText}),
      ).timeout(
        const Duration(seconds: 10), // Add timeout to catch network issues
        onTimeout: () {
          throw Exception('Request timed out. Check server at $serverUrl');
        },
      );

      print('Server Response: Status ${response.statusCode}, Body: ${response.body}'); // Log server response

      if (response.statusCode == 200) {
        final String responseBody = response.body;

        if (!mounted) return;

        // Step 3: Navigate to ResultScreen and await the returned ReceiptEntry
        final ReceiptEntry? result = await Navigator.push<ReceiptEntry>(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              data: responseBody,
              imageFile: _capturedImageFile!,
            ),
          ),
        );

        // Step 4: If user confirmed and a result was returned, add it and go back
        if (result != null && widget.onEntryAdded != null) {
          widget.onEntryAdded!(result);
          if (mounted) Navigator.pop(context); // Go back to main screen
        }
      } else {
        print('Server error: ${response.statusCode}. Using local OCR parsing.');
        // Fallback: Parse total locally
        String total = '0.00';
        String? date;
        String? merchant;
        for (var block in recognizedText.blocks) {
          final text = block.text.toLowerCase();
          // Extract total
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
          // Extract merchant (simple heuristic: first line often contains the store name)
          if (merchant == null && block.text.isNotEmpty) {
            merchant = block.text.split('\n').first;
          }
          // Extract date (look for date patterns like DD/MM/YYYY or YYYY-MM-DD)
          final dateMatch = RegExp(r'\d{1,2}/\d{1,2}/\d{2,4}|\d{4}-\d{2}-\d{2}').firstMatch(block.text);
          if (dateMatch != null) {
            date = dateMatch.group(0);
          }
        }

        final result = ReceiptEntry(
          imageFile: _capturedImageFile!,
          merchant: merchant ?? 'Unknown Store',
          currency: '£', // Default currency, adjust as needed
          total: total,
          category: 'General',
          date: date != null ? DateTime.tryParse(date) ?? DateTime.now() : DateTime.now(),
        );

        if (!mounted) return;

        // Navigate to ResultScreen with fallback data
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
        appBar: AppBar(title: const Text('Scan Receipt')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
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
                            margin: EdgeInsets.all(15),
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
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(color: Color(0xFF1C1D1F)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 30),
            onPressed: _toggleFlash,
          ),
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewControls() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      decoration: const BoxDecoration(color: Color(0xFF1C1D1F)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: _discardImage, child: _circleButton(icon: Icons.close)),
          GestureDetector(onTap: _sendImageAndNavigate, child: _circleButton(icon: Icons.check)),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(icon, color: Colors.black, size: 35),
    );
  }
}