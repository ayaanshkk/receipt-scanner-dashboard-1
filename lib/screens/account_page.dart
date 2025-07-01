import 'package:flutter/material.dart';
import 'forgot_password.dart';
import 'settings_page.dart';
import 'help_support_page.dart';

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
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.lock_reset_rounded, color: Theme.of(context).primaryColor),
            title: Text('Reset Password', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, thickness: 1),
          ListTile(
            leading: Icon(Icons.settings_rounded, color: Theme.of(context).primaryColor),
            title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, thickness: 1),
          ListTile(
            leading: Icon(Icons.support_agent_rounded, color: Theme.of(context).primaryColor),
            title: Text('Help & Support', style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HelpSupportPage()),
              );
            },
          ),
          Divider(color: Colors.grey.shade400, thickness: 1),
        ],
      ),
    );
  }
}