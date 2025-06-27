import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'scan_receipts.dart';

class DashboardPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const DashboardPage({required this.cameras, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text('Ready to scan your receipts?', style: TextStyle(fontSize: 18)),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanReceiptPage(cameras: cameras),
                    ),
                  );
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Scan Receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}