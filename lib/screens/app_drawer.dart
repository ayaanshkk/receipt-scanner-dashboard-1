import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'login_screen.dart';
import 'help_support_page.dart';

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
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
            leading: Icon(Icons.help_rounded),
            title: Text('Help and Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HelpSupportPage()),
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