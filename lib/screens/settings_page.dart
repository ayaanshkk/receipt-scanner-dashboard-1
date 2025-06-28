import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _largeText = false;
  bool _highContrast = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String _selectedTheme = themeProvider.themeMode == ThemeMode.light
        ? 'Light'
        : themeProvider.themeMode == ThemeMode.dark
            ? 'Dark'
            : 'System';

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme Mode'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              items: [
                DropdownMenuItem(value: 'Light', child: Text('Light')),
                DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                DropdownMenuItem(value: 'System', child: Text('System')),
              ],
              onChanged: (value) {
                final themeMode = value == 'Light'
                    ? ThemeMode.light
                    : value == 'Dark'
                        ? ThemeMode.dark
                        : ThemeMode.system;
                themeProvider.setThemeMode(themeMode);
              },
            ),
          ),
          SwitchListTile(
            title: Text('Large Text'),
            subtitle: Text('Increase text size for better readability'),
            secondary: Icon(Icons.text_fields_rounded),
            value: _largeText,
            onChanged: (value) {
              setState(() {
                _largeText = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Large Text: $value')),
                );
              });
            },
          ),
          SwitchListTile(
            title: Text('High Contrast'),
            subtitle: Text('Enhance visibility with high contrast colors'),
            secondary: Icon(Icons.contrast_rounded),
            value: _highContrast,
            onChanged: (value) {
              setState(() {
                _highContrast = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('High Contrast: $value')),
                );
              });
            },
          ),
          SwitchListTile(
            title: Text('Notifications'),
            subtitle: Text('Enable or disable app notifications'),
            secondary: Icon(Icons.notifications_active_rounded),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications: $value')),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}