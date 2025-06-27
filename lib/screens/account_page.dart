import 'package:flutter/material.dart';
import 'forgot_password.dart';

class AccountPage extends StatelessWidget {
  final String userId;

  const AccountPage({required this.userId, super.key});

  Future<void> _pickProfilePhoto(BuildContext context) async {
    // Simulate photo selection (no actual file picker for simplicity)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile photo updated for $userId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Text(
                  userId[0].toUpperCase(),
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: $userId', style: TextStyle(fontSize: 18)),
                  Text('Email: $userId@example.com', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            icon: Icon(Icons.lock_reset_rounded),
            label: Text('Reset Password'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
              );
            },
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_camera_rounded),
            label: Text('Set Profile Photo'),
            onPressed: () => _pickProfilePhoto(context),
          ),
        ],
      ),
    );
  }
}