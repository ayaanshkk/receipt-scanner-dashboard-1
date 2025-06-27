import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back, $userId!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Icon(Icons.waving_hand_rounded, size: 50, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}