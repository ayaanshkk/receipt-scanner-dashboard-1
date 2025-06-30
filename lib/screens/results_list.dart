import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'results_screen.dart'; // Assuming it's in the same folder or adjust import accordingly

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

  const ResultsListScreen({
    super.key, 
    required this.initialEntries,
    this.onEntriesChanged,
  });

  @override
  State<ResultsListScreen> createState() => _ResultsListScreenState();
}

class _ResultsListScreenState extends State<ResultsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ReceiptEntry> _allEntries = [];
  List<ReceiptEntry> _filteredEntries = [];

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
      if (query.isEmpty) {
        _filteredEntries = List.from(_allEntries);
      } else {
        _filteredEntries = _allEntries.where((entry) {
          final merchantMatch = entry.merchant.toLowerCase().contains(query);
          final categoryMatch = entry.category.toLowerCase().contains(query);
          final currencyMatch = entry.currency.toLowerCase().contains(query);
          final totalMatch = entry.total.toLowerCase().contains(query);
          return merchantMatch || categoryMatch || currencyMatch || totalMatch;
        }).toList();
      }
    });
  }

  void _addEntry(ReceiptEntry entry) {
    setState(() {
      _allEntries.add(entry);
      _filterEntries();
    });
    
    // Notify parent about the change
    if (widget.onEntriesChanged != null) {
      widget.onEntriesChanged!(_allEntries);
    }
  }

  void _removeEntry(ReceiptEntry entry) {
    setState(() {
      _allEntries.remove(entry);
      _filterEntries();
    });
    
    // Notify parent about the change
    if (widget.onEntriesChanged != null) {
      widget.onEntriesChanged!(_allEntries);
    }
  }

  String _formatCurrency(String currency, String total) {
  // Prevent double currency symbol (e.g., ££)
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
    // Navigate to ResultScreen with empty initial data & a placeholder image file
    // You'll want to provide an actual image file or image picker integration here
    final result = await Navigator.of(context).push<ReceiptEntry>(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          data: '{}', // empty JSON as initial
          imageFile: File(''), // TODO: provide a valid image file or pick image flow
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final groupedEntries = _groupByDate(_filteredEntries);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // Effectively hides the AppBar
    ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search & Filter Row
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
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter options coming soon')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grouped Entries List
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
    );
  }

Widget _buildReceiptCard(ReceiptEntry entry, Color cardColor, bool isDark) {
  final textColour = isDark ? Colors.white : Colors.black;
  final borderColour = isDark ? Colors.white : Colors.black;

  return Card(
    color: cardColor,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 2,
    child: SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Receipt image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 90,
              child: entry.imageFile.path.isNotEmpty
                  ? Image.file(entry.imageFile, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Receipt details
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

          // Category badge
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
          fontSize: 10, // As you requested
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
),
        ],
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