import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:receipt_scanner/screens/scan_receipts.dart';

class ReceiptEntry {
  final File imageFile;
  final String description;
  final double totalExclVat;
  final double vatPercentage;
  final double vatAmountAed;
  final double totalInclVat;
  final DateTime date;

  ReceiptEntry({
    required this.imageFile,
    required this.description,
    required this.totalExclVat,
    required this.vatPercentage,
    required this.vatAmountAed,
    required this.totalInclVat,
    required this.date,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'total_excl_vat': totalExclVat,
      'vat_percentage': vatPercentage,
      'vat_amount_aed': vatAmountAed,
      'total_incl_vat': totalInclVat,
      'date': DateFormat('dd/MM/yyyy').format(date),
    };
  }

  // Format for display
  String get formattedTotalInclVat => 'AED ${totalInclVat.toStringAsFixed(2)}';
  String get formattedTotalExclVat => 'AED ${totalExclVat.toStringAsFixed(2)}';
  String get formattedVatAmount => 'AED ${vatAmountAed.toStringAsFixed(2)}';
  String get formattedVatPercentage => '${vatPercentage.toStringAsFixed(1)}%';
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
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
  double? _minAmount;
  double? _maxAmount;

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
        final descriptionMatch = entry.description.toLowerCase().contains(query);
        final amountMatch = entry.totalInclVat.toString().contains(query);
        final searchMatch = query.isEmpty || descriptionMatch || amountMatch;

        // Date range filtering
        final dateMatch = (_startDate == null || !entry.date.isBefore(_startDate!)) &&
            (_endDate == null || !entry.date.isAfter(_endDate!));

        // Amount range filtering
        final amountRangeMatch = (_minAmount == null || entry.totalInclVat >= _minAmount!) &&
            (_maxAmount == null || entry.totalInclVat <= _maxAmount!);

        return searchMatch && dateMatch && amountRangeMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
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
          startDate: _startDate,
          endDate: _endDate,
          minAmount: _minAmount,
          maxAmount: _maxAmount,
          onApply: (DateTime? newStartDate, DateTime? newEndDate, double? newMinAmount, double? newMaxAmount) {
            setState(() {
              _startDate = newStartDate;
              _endDate = newEndDate;
              _minAmount = newMinAmount;
              _maxAmount = newMaxAmount;
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: textColour,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.formattedTotalInclVat,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColour,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'VAT: ${entry.formattedVatAmount} (${entry.formattedVatPercentage})',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColour.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 12),
                child: Text(
                  entry.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColour.withOpacity(0.6),
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
          content: Text('Are you sure you want to delete the receipt: ${entry.description}?'),
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
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final Function(DateTime?, DateTime?, double?, double?) onApply;
  final VoidCallback onClear;

  const FilterDialog({
    super.key,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTime? _tempStartDate;
  late DateTime? _tempEndDate;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;

  @override
  void initState() {
    super.initState();
    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    _minAmountController = TextEditingController(
      text: widget.minAmount?.toStringAsFixed(2) ?? '',
    );
    _maxAmountController = TextEditingController(
      text: widget.maxAmount?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
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
          _tempEndDate = null;
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
            const Text('Amount Range (AED)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Min Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'AED ',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'AED ',
                    ),
                  ),
                ),
              ],
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

            double? minAmount;
            double? maxAmount;
            
            try {
              if (_minAmountController.text.isNotEmpty) {
                minAmount = double.parse(_minAmountController.text);
              }
              if (_maxAmountController.text.isNotEmpty) {
                maxAmount = double.parse(_maxAmountController.text);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter valid amounts')),
              );
              return;
            }

            if (minAmount != null && maxAmount != null && maxAmount < minAmount) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Max amount cannot be less than min amount')),
              );
              return;
            }

            widget.onApply(_tempStartDate, _tempEndDate, minAmount, maxAmount);
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