import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _largeText = false;
  bool _highContrast = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Adjust text theme for large text
    final textTheme = Theme.of(context).textTheme.copyWith(
          titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: _largeText ? 24 : 20,
              ),
          bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: _largeText ? 18 : 16,
              ),
          bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: _largeText ? 16 : 14,
              ),
        );

    // Adjust theme for high contrast
    final highContrastTheme = Theme.of(context).copyWith(
      primaryColor:
          _highContrast ? Colors.blueAccent : Theme.of(context).primaryColor,
      textTheme: textTheme.apply(
        bodyColor: _highContrast
            ? Colors.black87
            : Theme.of(context).textTheme.bodyLarge?.color,
        displayColor: _highContrast
            ? Colors.black87
            : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      scaffoldBackgroundColor: _highContrast
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
    );

    return Theme(
      data: highContrastTheme,
      child: Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Theme Section
              Text(
                'Theme',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.dark_mode_rounded,
                    color: highContrastTheme.primaryColor),
                title: Text('Dark Mode', style: textTheme.bodyLarge),
                subtitle: Text('Toggle between light and dark theme',
                    style: textTheme.bodyMedium),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Dark Mode: ${value ? 'On' : 'Off'}')),
                    );
                  },
                ),
                onTap: () {
                  themeProvider.setThemeMode(
                      isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Dark Mode: ${isDarkMode ? 'Off' : 'On'}')),
                  );
                },
              ),
              Divider(color: Colors.grey.shade400, thickness: 1),
              SizedBox(height: 16),
              // Accessibility Section
              Text(
                'Accessibility',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.text_fields_rounded,
                    color: highContrastTheme.primaryColor),
                title: Text('Large Text', style: textTheme.bodyLarge),
                subtitle: Text('Increase text size for better readability',
                    style: textTheme.bodyMedium),
                onTap: () {
                  setState(() {
                    _largeText = !_largeText;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Large Text: $_largeText')),
                    );
                  });
                },
              ),
              Divider(color: Colors.grey.shade400, thickness: 1),
              ListTile(
                leading: Icon(Icons.contrast_rounded,
                    color: highContrastTheme.primaryColor),
                title: Text('High Contrast', style: textTheme.bodyLarge),
                subtitle: Text('Enhance visibility with high contrast colors',
                    style: textTheme.bodyMedium),
                onTap: () {
                  setState(() {
                    _highContrast = !_highContrast;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('High Contrast: $_highContrast')),
                    );
                  });
                },
              ),
              Divider(color: Colors.grey.shade400, thickness: 1),
              SizedBox(height: 16),
              // General Section
              Text(
                'General',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.notifications_active_rounded,
                    color: highContrastTheme.primaryColor),
                title: Text('Notifications', style: textTheme.bodyLarge),
                subtitle: Text('Check for app notifications',
                    style: textTheme.bodyMedium),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No new notifications')),
                  );
                },
              ),
              Divider(color: Colors.grey.shade400, thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}
