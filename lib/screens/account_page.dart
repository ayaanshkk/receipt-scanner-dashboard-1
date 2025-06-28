import 'package:flutter/material.dart';
import 'forgot_password.dart';

class AccountPage extends StatelessWidget {
  final String userId;

  const AccountPage({required this.userId, super.key});

  Future<void> _pickProfilePhoto(BuildContext context) async {
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
          Text('Account', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickProfilePhoto(context),
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, size: 20, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: $userId', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Email: $userId@example.com', style: Theme.of(context).textTheme.bodyMedium),
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
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.photo_camera_rounded),
            label: Text('Set Profile Photo'),
            onPressed: () => _pickProfilePhoto(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ],
      ),
    );
  }
}