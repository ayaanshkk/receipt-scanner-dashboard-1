import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String data;

  const ResultScreen({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Extracted Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(data, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}