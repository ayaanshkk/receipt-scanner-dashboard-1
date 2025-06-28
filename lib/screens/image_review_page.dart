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
      body: Column(
        children: [
          Expanded(
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
          Container(
            height: 80,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white, size: 40),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: Icon(Icons.check_rounded, color: Colors.white, size: 40),
                  onPressed: () => _sendImage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}