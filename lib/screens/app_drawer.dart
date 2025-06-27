import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'login_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userId;

  const AppDrawer({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userId),
            accountEmail: Text('$userId@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                userId[0].toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.settings_rounded),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage(cameras: [])),
              );
            },
          ),
        ],
      ),
    );
  }
}