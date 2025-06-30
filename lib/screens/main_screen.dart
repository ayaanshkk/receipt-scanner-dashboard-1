import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:receipt_scanner/screens/home_page.dart' as home;
import 'package:receipt_scanner/screens/results_list.dart';
import 'package:receipt_scanner/screens/account_page.dart';
import 'package:receipt_scanner/screens/scan_receipts.dart';
import 'package:receipt_scanner/screens/app_drawer.dart';

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String userId;

  const MainScreen({required this.cameras, required this.userId, super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Store receipt entries at the MainScreen level
  List<ReceiptEntry> _receiptEntries = [];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      home.HomePage(
        userId: widget.userId,
        cameras: widget.cameras,
        onEntryAdded: _addReceiptEntry,
        receiptEntries: _receiptEntries, onNavigateToReceiptsTab: () {  },
      ),
      Container(),
      ResultsListScreen(
        initialEntries: _receiptEntries,
        cameras: widget.cameras,
        onEntriesChanged: _updateReceiptEntries,
      ),
      AccountPage(userId: widget.userId),
    ];
  }

  // Callback to update receipt entries
  void _updateReceiptEntries(List<ReceiptEntry> newEntries) {
    setState(() {
      _receiptEntries = newEntries;
      // Update HomePage with new entries
      _pages[0] = home.HomePage(
        userId: widget.userId,
        cameras: widget.cameras,
        onEntryAdded: _addReceiptEntry,
        receiptEntries: _receiptEntries, onNavigateToReceiptsTab: () {  },
      );
      // Update ResultsListScreen
      _pages[2] = ResultsListScreen(
        initialEntries: _receiptEntries,
        cameras: widget.cameras,
        onEntriesChanged: _updateReceiptEntries,
      );
    });
  }

  // Method to add a single entry (called from scan flow)
  void _addReceiptEntry(ReceiptEntry entry) {
    setState(() {
      _receiptEntries.add(entry);
      // Update HomePage with new entries
      _pages[0] = home.HomePage(
        userId: widget.userId,
        cameras: widget.cameras,
        onEntryAdded: _addReceiptEntry,
        receiptEntries: _receiptEntries, onNavigateToReceiptsTab: () {  },
      );
      // Update ResultsListScreen
      _pages[2] = ResultsListScreen(
        initialEntries: _receiptEntries,
        cameras: widget.cameras,
        onEntriesChanged: _updateReceiptEntries,
      );
    });
  }

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanReceiptPage(
            cameras: widget.cameras,
            onEntryAdded: _addReceiptEntry,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final List<String> iconPaths = [
      'assets/icons/home-03-stroke-standard.svg',
      'assets/icons/camera-01-stroke-standard.svg',
      'assets/icons/license-stroke-standard.svg',
      'assets/icons/user-circle-stroke-standard.svg',
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              'assets/icons/menu-02-solid-standard.svg',
              width: 26,
              height: 26,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_getTitle(_currentIndex)),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/notification-02-stroke-standard.svg',
              width: 26,
              height: 26,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(userId: widget.userId),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: cardColor,
        height: 84,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(iconPaths.length, (index) {
            final selected = _currentIndex == index;

            return GestureDetector(
              onTap: () => _onTabTapped(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.only(top: 16, bottom: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      iconPaths[index],
                      width: 26,
                      height: 26,
                      color: selected ? Colors.green : Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Scan';
      case 2:
        return 'Receipts';
      case 3:
        return 'Account';
      default:
        return '';
    }
  }
}