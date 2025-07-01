import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help and Support'),
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
            const SizedBox(height: 16),
            _buildFAQCard(
              context,
              question: 'How do I scan a receipt?',
              answer: 'To scan a receipt, go to the Home page and tap "Create New". Use the camera to capture the receipt image, then tap the checkmark to process it. The app will extract details like the store name and total, which you can review and confirm.',
              cardColor: cardColor,
              shadowColor: shadowColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildFAQCard(
              context,
              question: 'How do I upload multiple receipts from my gallery?',
              answer: 'On the Home page, tap "Upload Receipt". Select multiple images from your gallery, and the app will process each one. You’ll be prompted to review and confirm the extracted details for each receipt.',
              cardColor: cardColor,
              shadowColor: shadowColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildFAQCard(
              context,
              question: 'What should I do if the app can’t connect to the server?',
              answer: 'If you see a "Request timed out" error, ensure your server is running at http://10.0.2.2:3001/ocr (for emulators) or your local IP (e.g., http://192.168.0.66:3001/ocr for physical devices). Run `adb reverse tcp:3001 tcp:3001` for emulators, check your firewall settings, and verify the server is listening on port 3001. The app will use local processing as a fallback if the server is unavailable.',
              cardColor: cardColor,
              shadowColor: shadowColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildFAQCard(
              context,
              question: 'How do I view my scanned receipts?',
              answer: 'After scanning or uploading receipts, they appear in the Receipts tab on the Home page. Tap any receipt card to view its details, including the store name, total, and date.',
              cardColor: cardColor,
              shadowColor: shadowColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _buildFAQCard(
              context,
              question: 'Can I export my receipt data?',
              answer: 'The export feature is not yet implemented. Stay tuned for updates in future versions of the app.',
              cardColor: cardColor,
              shadowColor: shadowColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(
    BuildContext context, {
    required String question,
    required String answer,
    required Color cardColor,
    required Color shadowColor,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
          iconColor: Theme.of(context).primaryColor,
          collapsedIconColor: textColor,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.8),
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}