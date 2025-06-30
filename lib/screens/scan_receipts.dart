import 'dart:io';
import'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_scanner/screens/results_list.dart';
import 'dart:convert';
import 'results_screen.dart';
import 'package:image_picker/image_picker.dart';

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

@override
void initState() {
super.initState();
_initializeCamera();
}

Future _initializeCamera() async {
if (widget.cameras.isNotEmpty) {
_controller = CameraController(widget.cameras[0], ResolutionPreset.high);
await _controller!.initialize();
await _controller!.setFlashMode(FlashMode.off);
setState(() {});
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
setState(() {});
}
}

Future _captureImage() async {
if (_controller == null) return;
final image = await _controller!.takePicture();
_capturedImageFile = File(image.path);
setState(() {});
}

Future<void> _sendImageAndNavigate() async {
  if (_capturedImageFile == null) return;

  try {
    // Step 1: Perform on-device OCR
    final inputImage = InputImage.fromFilePath(_capturedImageFile!.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    final String rawText = recognizedText.text;

    // Step 2: Send the extracted text to your backend server
    final response = await http.post(
      Uri.parse('http://192.168.0.66:3000/ocr'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': rawText}),
    );

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
        Navigator.pop(context); // Go back to main screen
      }
    } else {
      Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error: $e');
  }
}


void _discardImage() {
_capturedImageFile = null;
setState(() {});
}

Future<void> _pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _capturedImageFile = File(pickedFile.path);
      setState(() {});
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error picking image: $e');
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
        : CameraPreview(_controller!),

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
height: 100,
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
height: 100,
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