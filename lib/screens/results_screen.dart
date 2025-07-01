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

      _merchantController = TextEditingController(
        text: _toTitleCase(parsed['establishment'] ?? ''),
      );

      String dateRaw = parsed['date']?.toString() ?? '';
      DateTime? parsedDate = _parseDate(dateRaw);
      _selectedDate = parsedDate ?? DateTime.now(); // Default to today if parsing fails
      _dateController = TextEditingController(
        text: DateFormat('MMMM d, yyyy').format(_selectedDate!),
      );

      final currency = parsed['currency']?.toString() ?? '';
      _currencyController = TextEditingController(
        text: _currencies.contains(currency) ? currency : '£',
      );

      _totalController = TextEditingController(text: parsed['total']?.toString() ?? '');
      _vatController = TextEditingController(text: parsed['VAT']?.toString() ?? '');

      final methodRaw = parsed['method_of_payment']?.toString() ?? '';
      _selectedPaymentMethod = _findBestPaymentMethodMatch(methodRaw);

      final categoryRaw = parsed['category']?.toString() ?? '';
      _selectedCategory = _findBestCategoryMatch(categoryRaw);
    } catch (e) {
      print('Error parsing data: $e');
      _merchantController = TextEditingController();
      _dateController = TextEditingController();
      _currencyController = TextEditingController(text: '£');
      _totalController = TextEditingController();
      _vatController = TextEditingController();
      _selectedCategory = null;
      _selectedPaymentMethod = null;
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('MMMM d, yyyy').format(_selectedDate!);
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    final twoDigitYearPatterns = [
      RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})$'), // dd/mm/yy or mm-dd-yy
      RegExp(r'^(\d{2})[\/\-](\d{1,2})[\/\-](\d{1,2})$'), // yy/mm/dd
    ];

    for (final pattern in twoDigitYearPatterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        int day = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);
        year += (year < 50 ? 2000 : 1900);
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF29A165), // Use green for date picker
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
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
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            TextField(
              controller: _vatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'VAT',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (_selectedDate == null || _dateController.text.isEmpty) {
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