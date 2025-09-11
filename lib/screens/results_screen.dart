import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:receipt_scanner/screens/results_list.dart'; // Adjust import if necessary

class ResultScreen extends StatefulWidget {
  final String data;
  final File imageFile;

  const ResultScreen({required this.data, required this.imageFile, super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _totalExclVatController;
  late TextEditingController _vatPercentageController;
  late TextEditingController _vatAmountAedController;
  late TextEditingController _totalInclVatController;

  @override
  void initState() {
    super.initState();
    _populateFieldsFromData();
  }

  String _toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  void _populateFieldsFromData() {
    try {
      final parsed = jsonDecode(widget.data);

      _descriptionController = TextEditingController(
        text: _toTitleCase(parsed['description'] ?? ''),
      );

      _totalExclVatController = TextEditingController(
        text: parsed['total_excl_vat']?.toString() ?? '0.00',
      );

      _vatPercentageController = TextEditingController(
        text: parsed['vat_percentage']?.toString() ?? '0',
      );

      _vatAmountAedController = TextEditingController(
        text: parsed['vat_amount_aed']?.toString() ?? '0.00',
      );

      _totalInclVatController = TextEditingController(
        text: parsed['total_incl_vat']?.toString() ?? '0.00',
      );
    } catch (e) {
      print('Error parsing data: $e');
      _descriptionController = TextEditingController();
      _totalExclVatController = TextEditingController(text: '0.00');
      _vatPercentageController = TextEditingController(text: '0');
      _vatAmountAedController = TextEditingController(text: '0.00');
      _totalInclVatController = TextEditingController(text: '0.00');
    }
  }

  void _openFullScreenImage() {
    if (widget.imageFile.existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImage(imageFile: widget.imageFile),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image file not found')),
      );
    }
  }

  bool _validateFields() {
    // Check if description is not empty
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return false;
    }

    // Validate numeric fields
    try {
      double.parse(_totalExclVatController.text);
      double.parse(_vatPercentageController.text);
      double.parse(_vatAmountAedController.text);
      double.parse(_totalInclVatController.text);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Receipt Details',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image preview with tap to open
            GestureDetector(
              onTap: _openFullScreenImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.imageFile.existsSync()
                    ? Image.file(widget.imageFile, width: double.infinity, height: 200, fit: BoxFit.cover)
                    : Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Description field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                helperText: 'Brief description of the purchase',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Total Excl. VAT field
            TextField(
              controller: _totalExclVatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Excl. VAT (AED)',
                border: OutlineInputBorder(),
                prefixText: 'AED ',
              ),
            ),
            const SizedBox(height: 16),
            
            // VAT percentage and amount row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _vatPercentageController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'VAT %',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _vatAmountAedController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'VAT (AED)',
                      border: OutlineInputBorder(),
                      prefixText: 'AED ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total Incl. VAT field
            TextField(
              controller: _totalInclVatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'TOTAL Incl. VAT (AED)',
                border: OutlineInputBorder(),
                prefixText: 'AED ',
              ),
            ),
            const SizedBox(height: 24),
            
            // Add Entry button
            GestureDetector(
              onTap: () {
                if (!_validateFields()) return;

                final newEntry = ReceiptEntry(
                  imageFile: widget.imageFile,
                  description: _descriptionController.text.trim(),
                  totalExclVat: double.parse(_totalExclVatController.text),
                  vatPercentage: double.parse(_vatPercentageController.text),
                  vatAmountAed: double.parse(_vatAmountAedController.text),
                  totalInclVat: double.parse(_totalInclVatController.text),
                  date: DateTime.now(),
                );

                Navigator.of(context).pop(newEntry);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF29A165),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Add Entry',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalExclVatController.dispose();
    _vatPercentageController.dispose();
    _vatAmountAedController.dispose();
    _totalInclVatController.dispose();
    super.dispose();
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({required this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Center(
        child: imageFile.existsSync()
            ? Image.file(imageFile, fit: BoxFit.contain)
            : const Text('Image not found', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}