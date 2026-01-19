import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt_scanner/screens/scan_receipts.dart';
import 'package:receipt_scanner/screens/results_list.dart';
import 'package:receipt_scanner/screens/results_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Configurable server URL
const String serverUrl = 'https://receipt-scanner-backend-yl7m.onrender.com/api/receipts/process-receipt';

class HomePage extends StatelessWidget {
  final String userId;
  final List<CameraDescription> cameras;
  final Function(ReceiptEntry) onEntryAdded;
  final List<ReceiptEntry> receiptEntries;
  final VoidCallback onNavigateToReceiptsTab;

  const HomePage({
    required this.userId,
    required this.cameras,
    required this.onEntryAdded,
    required this.receiptEntries,
    required this.onNavigateToReceiptsTab,
    super.key,
  });

  Future<void> _uploadReceipts(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // Allow multiple image selection from gallery
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        // Process each image to extract receipt details
        final List<ReceiptEntry> newEntries = [];
        for (var image in images) {
          final File imageFile = File(image.path);

          // Perform OCR on the image
          final inputImage = InputImage.fromFilePath(image.path);
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          final String rawText = recognizedText.text;
          print('OCR Text: $rawText'); // Log OCR output for debugging

          // Send the extracted text to the backend server
          final response = await http.post(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': rawText}),
          ).timeout(
            const Duration(seconds: 10), // Add timeout to catch network issues
            onTimeout: () {
              throw Exception('Request timed out. Check server at $serverUrl');
            },
          );

          print('Server Response: Status ${response.statusCode}, Body: ${response.body}'); // Log server response

          if (response.statusCode == 200) {
            final String responseBody = response.body;

            if (!context.mounted) return;

            // Navigate to ResultScreen and await the returned ReceiptEntry
            final ReceiptEntry? result = await Navigator.push<ReceiptEntry>(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  data: responseBody,
                  imageFile: imageFile,
                ),
              ),
            );

            // If user confirmed and a result was returned, add it
            if (result != null) {
              newEntries.add(result);
            }
          } else {
            Fluttertoast.showToast(
              msg: 'Server error for image: ${response.statusCode}. Using local OCR parsing.',
            );
            
            // Fallback: Parse data locally with new VAT structure
            String description = 'Purchase';
            double totalExclVat = 0.0;
            double vatPercentage = 5.0; // Default UAE VAT
            double vatAmountAed = 0.0;
            double totalInclVat = 0.0;
            
            for (var block in recognizedText.blocks) {
              final text = block.text.toLowerCase();
              
              // Extract total amount (look for patterns like "total: 100.50")
              final totalMatch = RegExp(r'total[:\s]*(\d+\.?\d*)').firstMatch(text);
              if (totalMatch != null) {
                totalInclVat = double.tryParse(totalMatch.group(1) ?? '0') ?? 0.0;
              }
              
              // Extract VAT information
              final vatMatch = RegExp(r'vat[:\s]*(\d+\.?\d*)').firstMatch(text);
              if (vatMatch != null) {
                vatAmountAed = double.tryParse(vatMatch.group(1) ?? '0') ?? 0.0;
              }
              
              // Try to extract merchant/description from first non-empty line
              if (description == 'Purchase' && block.text.trim().isNotEmpty) {
                final lines = block.text.split('\n');
                for (var line in lines) {
                  if (line.trim().isNotEmpty && line.length > 2) {
                    description = line.trim();
                    break;
                  }
                }
              }
            }
            
            // Calculate missing values
            if (totalInclVat > 0 && vatAmountAed > 0) {
              totalExclVat = totalInclVat - vatAmountAed;
              vatPercentage = (vatAmountAed / totalExclVat) * 100;
            } else if (totalInclVat > 0) {
              // Assume 5% VAT
              totalExclVat = totalInclVat / 1.05;
              vatAmountAed = totalInclVat - totalExclVat;
              vatPercentage = 5.0;
            }

            if (!context.mounted) return;

            final result = ReceiptEntry(
              imageFile: imageFile,
              description: description,
              totalExclVat: totalExclVat,
              vatPercentage: vatPercentage,
              vatAmountAed: vatAmountAed,
              totalInclVat: totalInclVat,
              date: DateTime.now(),
            );

            final confirmedResult = await Navigator.push<ReceiptEntry>(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  data: jsonEncode({
                    'description': description,
                    'total_excl_vat': totalExclVat,
                    'vat_percentage': vatPercentage,
                    'vat_amount_aed': vatAmountAed,
                    'total_incl_vat': totalInclVat,
                  }),
                  imageFile: imageFile,
                ),
              ),
            );

            if (confirmedResult != null) {
              newEntries.add(confirmedResult);
            }
          }
        }

        // Add each confirmed entry using the callback
        for (var entry in newEntries) {
          onEntryAdded(entry);
        }

        if (newEntries.isNotEmpty && context.mounted) {
          // Pop back to the main screen and switch to Receipts tab
          Navigator.popUntil(context, (route) => route.isFirst);
          onNavigateToReceiptsTab();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newEntries.length} receipt(s) uploaded successfully')),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No receipts were confirmed. Check server connection.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading receipts: $e')),
      );
      print('Error details: $e'); // Log full error for debugging
    } finally {
      await textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customCardColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F5F5);
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 34),

          // Welcome Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.waving_hand, color: Theme.of(context).primaryColor, size: 30),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Action Cards Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _HomeActionCard(
                  title: 'Create New',
                  icon: CupertinoIcons.plus_circle,
                  iconColor: iconColor,
                  onTap: () async {
                    final result = await Navigator.push<ReceiptEntry>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanReceiptPage(
                          cameras: cameras,
                          onEntryAdded: onEntryAdded,
                        ),
                      ),
                    );

                    if (result != null) {
                      onEntryAdded(result);
                      Navigator.popUntil(context, (route) => route.isFirst);
                      onNavigateToReceiptsTab();
                    }
                  },
                ),
                _HomeActionCard(
                  title: 'Upload Receipt',
                  icon: CupertinoIcons.camera,
                  iconColor: iconColor,
                  onTap: () => _uploadReceipts(context),
                ),

                _HomeActionCard(
                  title: 'View Analytics',
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  iconColor: iconColor,
                  onTap: () async {
                    const analyticsUrl = 'https://demo-analytics--receipt-scanner.netlify.app';
                    final Uri url = Uri.parse(analyticsUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open analytics link')),
                        );
                      }
                    }
                  },
                ),
                _HomeActionCard(
                  title: 'Export',
                  icon: CupertinoIcons.arrow_up_doc,
                  iconColor: iconColor,
                  onTap: () async {
                    const exportUrl = 'https://demo-export--receipt-scanner.netlify.app';
                    final Uri url = Uri.parse(exportUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open export link')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Receipts Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Text(
              'Receipts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: receiptEntries.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final bool isFirst = index == 0;
                final bool isLast = index == receiptEntries.length - 1;

                return Padding(
                  padding: EdgeInsets.only(
                    left: isFirst ? 27 : 8,
                    right: isLast ? 27 : 0,
                  ),
                  child: SizedBox(
                    width: 139,
                    height: 160,
                    child: ReceiptCard(entry: receiptEntries[index]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// Updated ReceiptCard Widget
class ReceiptCard extends StatelessWidget {
  final ReceiptEntry entry;

  const ReceiptCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardColor = isDark 
        ? const Color(0xFF1C1C1E)
        : Colors.white;
    
    final shadowColor = isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.06);
    
    final dateColor = isDark 
        ? Colors.white60 
        : const Color(0xFF8E8E93);
    
    final storeColor = isDark 
        ? Colors.white54 
        : const Color(0xFF8E8E93);

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // TODO: Handle receipt tap
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                '${months[entry.date.month - 1]} ${entry.date.day}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: dateColor,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              
              // Amount
              Text(
                entry.formattedTotalInclVat,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              
              // Description with subtle background
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: storeColor,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _HomeActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardColor = isDark 
        ? const Color(0xFF1C1C1E)
        : Colors.white;
    
    final shadowColor = isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);
    
    final pressedColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: pressedColor.withOpacity(0.3),
            highlightColor: pressedColor.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}