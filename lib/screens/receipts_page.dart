import 'package:flutter/material.dart';

class ReceiptsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 50, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'No receipts scanned yet.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}