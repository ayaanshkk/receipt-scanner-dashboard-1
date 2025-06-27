import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Large Text'),
            subtitle: Text('Increase text size for better readability'),
            secondary: Icon(Icons.text_fields_rounded),
            value: _largeText,
            onChanged: (value) {
              setState(() {
                _largeText = value;
                // Apply text size change (simulated)
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
                // Apply contrast change (simulated)
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
                // Toggle notifications (simulated)
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