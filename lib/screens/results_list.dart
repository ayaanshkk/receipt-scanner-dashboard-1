import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:receipt_scanner/screens/scan_receipts.dart';

class ReceiptEntry {
  final File imageFile;
  final String merchant;
  final String currency;
  final String total;
  final String category;
  final DateTime date;

  ReceiptEntry({
    required this.imageFile,
    required this.merchant,
    required this.currency,
    required this.total,
    required this.category,
    required this.date,
  });
}

class ResultsListScreen extends StatefulWidget {
  final List<ReceiptEntry> initialEntries;
  final Function(List<ReceiptEntry>)? onEntriesChanged;
  final List<CameraDescription> cameras;

  const ResultsListScreen({
    super.key,
    required this.initialEntries,
    required this.cameras,
    this.onEntriesChanged,
  });

  @override
  State<ResultsListScreen> createState() => _ResultsListScreenState();
}

class _ResultsListScreenState extends State<ResultsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReceiptEntry> _allEntries = [];
  List<ReceiptEntry> _filteredEntries = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedCategories = [];

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

  @override
  void initState() {
    super.initState();
    _allEntries = List.from(widget.initialEntries);
    _filteredEntries = List.from(_allEntries);
    _searchController.addListener(_filterEntries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEntries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        // Search query filtering
        final merchantMatch = entry.merchant.toLowerCase().contains(query);
        final categoryMatch = entry.category.toLowerCase().contains(query);
        final currencyMatch = entry.currency.toLowerCase().contains(query);
        final totalMatch = entry.total.toLowerCase().contains(query);
        final searchMatch = query.isEmpty || merchantMatch || categoryMatch || currencyMatch || totalMatch;

        // Date range filtering
        final dateMatch = (_startDate == null || !entry.date.isBefore(_startDate!)) &&
            (_endDate == null || !entry.date.isAfter(_endDate!));

        // Category filtering
        final categoryMatchFilter = _selectedCategories.isEmpty || _selectedCategories.contains(entry.category);

        return searchMatch && dateMatch && categoryMatchFilter;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategories = [];
      _filterEntries();
    });
  }

  void _addEntry(ReceiptEntry entry) {
    setState(() {
      _allEntries.add(entry);
      _filterEntries();
    });

    if (widget.onEntriesChanged != null) {
      widget.onEntriesChanged!(_allEntries);
    }
  }

  void _removeEntry(ReceiptEntry entry) {
    setState(() {
      _allEntries.remove(entry);
      _filterEntries();
    });

    if (widget.onEntriesChanged != null) {
      widget.onEntriesChanged!(_allEntries);
    }
  }

  String _formatCurrency(String currency, String total) {
    final hasSymbol = RegExp(r'^[£$€]').hasMatch(total.trim());
    return hasSymbol ? total : '$currency $total';
  }

  Map<String, List<ReceiptEntry>> _groupByDate(List<ReceiptEntry> entries) {
    final Map<String, List<ReceiptEntry>> map = {};

    for (var entry in entries) {
      final key = "${_monthName(entry.date.month)} ${entry.date.day}";
      map.putIfAbsent(key, () => []).add(entry);
    }

    return map;
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  Future<void> _navigateToAddEntry() async {
    final result = await Navigator.of(context).push<ReceiptEntry>(
      MaterialPageRoute(
        builder: (_) => ScanReceiptPage(
          cameras: widget.cameras,
          onEntryAdded: _addEntry,
        ),
      ),
    );

    if (result != null) {
      _addEntry(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry added successfully')),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          categories: _categories,
          selectedCategories: _selectedCategories,
          startDate: _startDate,
          endDate: _endDate,
          onApply: (DateTime? newStartDate, DateTime? newEndDate, List<String> newCategories) {
            setState(() {
              _startDate = newStartDate;
              _endDate = newEndDate;
              _selectedCategories = newCategories;
              _filterEntries();
            });
          },
          onClear: _clearFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final groupedEntries = _groupByDate(_filteredEntries);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search receipts...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined, color: isDark ? Colors.white : Colors.black),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: groupedEntries.isEmpty
                  ? const Center(child: Text('No receipts found'))
                  : ListView(
                      children: groupedEntries.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...entry.value
                                .map((e) => _buildReceiptCard(e, cardColor, isDark))
                                .toList(),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEntry,
        backgroundColor: const Color(0xFF29A165),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReceiptCard(ReceiptEntry entry, Color cardColor, bool isDark) {
    final textColour = isDark ? Colors.white : Colors.black;
    final borderColour = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onLongPress: () => _showDeleteConfirmation(entry),
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 90,
                  child: entry.imageFile.existsSync()
                      ? Image.file(entry.imageFile, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.merchant,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColour,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(entry.currency, entry.total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColour,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 12),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColour.withOpacity(0.54)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entry.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ReceiptEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Receipt'),
          content: Text('Are you sure you want to delete the receipt from ${entry.merchant}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _removeEntry(entry);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class FilterDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> selectedCategories;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?, List<String>) onApply;
  final VoidCallback onClear;

  const FilterDialog({
    super.key,
    required this.categories,
    required this.selectedCategories,
    this.startDate,
    this.endDate,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTime? _tempStartDate;
  late DateTime? _tempEndDate;
  late List<String> _tempSelectedCategories;

  @override
  void initState() {
    super.initState();
    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    _tempSelectedCategories = List.from(widget.selectedCategories);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF29A165),
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
        _tempStartDate = picked;
        if (_tempEndDate != null && _tempEndDate!.isBefore(_tempStartDate!)) {
          _tempEndDate = null; // Reset end date if it's before start date
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tempEndDate ?? _tempStartDate ?? DateTime.now(),
      firstDate: _tempStartDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF29A165),
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
        _tempEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Filter Receipts'),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: _selectStartDate,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectStartDate,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      hintText: _tempStartDate != null
                          ? DateFormat('MMMM d, yyyy').format(_tempStartDate!)
                          : 'Select start date',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: _selectEndDate,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectEndDate,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      hintText: _tempEndDate != null
                          ? DateFormat('MMMM d, yyyy').format(_tempEndDate!)
                          : 'Select end date',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ChipsChoice<String>.multiple(
              value: _tempSelectedCategories,
              onChanged: (val) => setState(() => _tempSelectedCategories = val),
              choiceItems: C2Choice.listFrom<String, String>(
                source: widget.categories,
                value: (i, v) => v,
                label: (i, v) => v,
              ),
              choiceStyle: C2ChoiceStyle(
                color: isDark ? Colors.white : Colors.black,
                borderColor: isDark ? Colors.white : Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              choiceActiveStyle: C2ChoiceStyle(
                color: Colors.white,
                brightness: Brightness.dark,
                borderColor: const Color(0xFF29A165),
              ),
              wrapped: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClear,
          child: Text(
            'Clear Filters',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_tempStartDate != null && _tempEndDate != null && _tempEndDate!.isBefore(_tempStartDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('End date cannot be before start date')),
              );
              return;
            }
            widget.onApply(_tempStartDate, _tempEndDate, _tempSelectedCategories);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Apply',
            style: TextStyle(color: Color(0xFF29A165)),
          ),
        ),
      ],
    );
  }
}