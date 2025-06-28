import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'image_review_page.dart';

class ScanReceiptPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ScanReceiptPage({required this.cameras, super.key});

  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  CameraController? _controller;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
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
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageReviewPage(imageFile: File(pickedFile.path)),
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null) {
      final image = await _controller!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageReviewPage(imageFile: File(image.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.photo_library_rounded, color: Colors.white, size: 30),
              onPressed: _pickImageFromGallery,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              color: Theme.of(context).primaryColor,
              child: Center(
                child: GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}