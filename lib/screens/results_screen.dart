import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'results_list.dart'; // Adjust import if necessary

class ResultScreen extends StatefulWidget {
  final String data;
  final File imageFile;

  const ResultScreen({required this.data, required this.imageFile, super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _dateController;
  late TextEditingController _currencyController;
  late TextEditingController _totalController;
  late TextEditingController _vatController;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Residents Expenses',
    'Rates & Water',
    'Gas & Electric',
    'Insurance',
    'Advertising & Marketing',
    'Telephone & Mobile',
    'Stationery & Postage',
    'Motor Fuel',
    'Motor Repairs',
    'Motor Insurance & Road Tax',
    'Travel',
    'Parking & Misc',
    'H&S',
    'Legal',
    'Professional',
    'Accountancy & Subscriptions',
    'Repairs, Renewals & Maintenance',
    'Cleaning, Waste & Pest Control',
    'Donations',
    'Fixed Assets',
    'Misc & others'
  ];

  final List<String> _paymentMethods = ['Payment card', 'Cash', 'Online Payment'];

  final List<String> _currencies = ['£', '\$', '€', '¥', '₹', '₩', '₽'];

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
      // print('Parsed JSON: $parsed'); // Debug print

      _merchantController = TextEditingController(
        text: _toTitleCase(parsed['establishment'] ?? ''),
      );

      // Improved date parsing
      String dateRaw = parsed['date']?.toString() ?? '';
      // print('Date raw: $dateRaw'); // Debug print
      DateTime? parsedDate = _parseDate(dateRaw);
      _selectedDate = parsedDate;
      _dateController = TextEditingController(
        text: parsedDate != null ? DateFormat('MMMM d, yyyy').format(parsedDate) : dateRaw,
      );

      // Currency
      final currency = parsed['currency']?.toString() ?? '';
      _currencyController = TextEditingController(
        text: _currencies.contains(currency) ? currency : '£',
      );

      _totalController = TextEditingController(text: parsed['total']?.toString() ?? '');
      _vatController = TextEditingController(text: parsed['VAT']?.toString() ?? '');

      // Improved payment method matching
      final methodRaw = parsed['method_of_payment']?.toString() ?? '';
      // print('Method raw: $methodRaw'); // Debug print
      _selectedPaymentMethod = _findBestPaymentMethodMatch(methodRaw);
      // print('Selected payment method: $_selectedPaymentMethod'); // Debug print

      // Improved category matching
      final categoryRaw = parsed['category']?.toString() ?? '';
      // print('Category raw: $categoryRaw'); // Debug print
      _selectedCategory = _findBestCategoryMatch(categoryRaw);
      // print('Selected category: $_selectedCategory'); // Debug print
    } catch (e) {
      // print('Error parsing data: $e'); // Debug print
      _merchantController = TextEditingController();
      _dateController = TextEditingController();
      _currencyController = TextEditingController(text: '£');
      _totalController = TextEditingController();
      _vatController = TextEditingController();
      _selectedCategory = null;
      _selectedPaymentMethod = null;
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    // Handle two-digit years explicitly (e.g., 25/06/25 or 06-25-25)
    final twoDigitYearPatterns = [
      RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})$'), // dd/mm/yy or mm-dd-yy
      RegExp(r'^(\d{2})[\/\-](\d{1,2})[\/\-](\d{1,2})$'), // yy/mm/dd (rare)
    ];

    for (final pattern in twoDigitYearPatterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        int day = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);

        // Assume year 20xx for 2 digit years less than 50
        year += (year < 50 ? 2000 : 1900);

        try {
          return DateTime(year, month, day);
        } catch (_) {
          // If invalid, continue to next pattern
        }
      }
    }

    // Try parsing common formats
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(dateStr);
    } catch (_) {}

    try {
      return DateFormat('MM-dd-yyyy').parseStrict(dateStr);
    } catch (_) {}

    try {
      return DateFormat.yMd().parseStrict(dateStr);
    } catch (_) {}

    try {
      return DateFormat('MMMM d, yyyy').parseStrict(dateStr);
    } catch (_) {}

    // Fallback to DateTime.parse (ISO)
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    return null;
  }

  String? _findBestPaymentMethodMatch(String method) {
    final lowerMethod = method.toLowerCase();

    if (lowerMethod.contains('card') || lowerMethod.contains('credit') || lowerMethod.contains('debit')) {
      return 'Payment card';
    }
    if (lowerMethod.contains('cash')) {
      return 'Cash';
    }
    if (lowerMethod.contains('online') || lowerMethod.contains('paypal') || lowerMethod.contains('bank transfer')) {
      return 'Online Payment';
    }
    return null;
  }

  String? _findBestCategoryMatch(String category) {
    if (category.isEmpty) return null;
    final lowerCategory = category.toLowerCase();

    for (var cat in _categories) {
      if (cat.toLowerCase() == lowerCategory) {
        return cat;
      }
    }

    // If no exact match, check for partial matches (e.g., if category contains keywords)
    for (var cat in _categories) {
      if (lowerCategory.contains(cat.toLowerCase().split(' ')[0])) {
        return cat;
      }
    }

    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image preview
            if (widget.imageFile.path.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(widget.imageFile, width: double.infinity, height: 200, fit: BoxFit.cover),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
              ),

            const SizedBox(height: 20),

            // Merchant field
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Date field with date picker
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 16),

            // Currency and total fields in a row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // VAT field
            TextField(
              controller: _vatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'VAT',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),

            const SizedBox(height: 16),

            // Payment method dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: _paymentMethods
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              },
            ),

            const SizedBox(height: 32),

            // Add Entry button
            GestureDetector(
              onTap: () {
                if (_selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a valid date')),
                  );
                  return;
                }

                final newEntry = ReceiptEntry(
                  imageFile: widget.imageFile,
                  merchant: _merchantController.text,
                  currency: _currencyController.text,
                  total: _totalController.text,
                  category: _selectedCategory ?? 'Misc & others',
                  date: _selectedDate!,
                );

                Navigator.of(context).pop(newEntry);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF29A165),
                  borderRadius: BorderRadius.circular(20),
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
}
