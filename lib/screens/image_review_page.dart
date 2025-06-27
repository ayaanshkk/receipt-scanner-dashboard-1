import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'results_screen.dart';

class ImageReviewPage extends StatelessWidget {
  final File imageFile;

  const ImageReviewPage({required this.imageFile, super.key});

  Future<void> _sendImage(BuildContext context) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final response = await http.post(
        Uri.parse('https://your-server-url.com/ocr'),
        headers: {'Content-Type': 'application/octet-stream'},
        body: bytes,
      );
      if (response.statusCode == 200) {
        final data = response.body;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(data: data)),
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to process image');
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.file(imageFile, fit: BoxFit.cover)),
          Positioned(
            bottom: 50,
            left: 50,
            child: IconButton(
              icon: Icon(Icons.close_rounded, size: 50, color: Colors.red),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: IconButton(
              icon: Icon(Icons.check_rounded, size: 50, color: Colors.green),
              onPressed: () => _sendImage(context),
            ),
          ),
        ],
      ),
    );
  }
}