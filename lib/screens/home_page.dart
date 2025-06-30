import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:receipt_scanner/screens/scan_receipts.dart';
import 'package:receipt_scanner/screens/results_list.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final List<CameraDescription> cameras;
  final Function(ReceiptEntry) onEntryAdded; // Added callback

  const HomePage({
    required this.userId,
    required this.cameras,
    required this.onEntryAdded, // Added to constructor
    super.key,
  });

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
                  onTap: () {
                    // Navigate to ScanReceiptPage with callback
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanReceiptPage(
                          cameras: cameras,
                          onEntryAdded: onEntryAdded, // Pass callback
                        ),
                      ),
                    );
                  },
                ),
                _HomeActionCard(
                  title: 'Upload Receipt',
                  icon: CupertinoIcons.camera,
                  iconColor: iconColor,
                  onTap: () {
                    // TODO: Handle Upload
                  },
                ),
                _HomeActionCard(
                  title: 'View Analytics',
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  iconColor: iconColor,
                  onTap: () {
                    // TODO: Handle Analytics
                  },
                ),
                _HomeActionCard(
                  title: 'Export',
                  icon: CupertinoIcons.arrow_up_doc,
                  iconColor: iconColor,
                  onTap: () {
                    // TODO: Handle Export
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
              itemCount: 5,
              itemBuilder: (context, index) {
                final bool isFirst = index == 0;
                final bool isLast = index == 4;

                return Padding(
                  padding: EdgeInsets.only(
                    left: isFirst ? 27 : 8,
                    right: isLast ? 27 : 0,
                  ),
                  child: SizedBox(
                    width: 139,
                    height: 160,
                    child: ReceiptCard(index: index),
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
  final int index;

  const ReceiptCard({required this.index, super.key});

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

    final monthIndex = (6 + index) % 12;
    final day = 25 + index;

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
                '${months[monthIndex]} $day',
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
                '£${(100 + index * 10).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              
              // Store name with subtle background
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Store',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: storeColor,
                    letterSpacing: -0.1,
                  ),
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
    
    // Apple-style colors
    final cardColor = isDark 
        ? const Color(0xFF1C1C1E)  // Dark mode card
        : Colors.white;            // Light mode card
    
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
          borderRadius: BorderRadius.circular(16), // Apple's preferred radius
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            if (!isDark) // Additional subtle shadow for light mode
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
                  // Icon with subtle background
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
                      letterSpacing: -0.2, // Apple's subtle letter spacing
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