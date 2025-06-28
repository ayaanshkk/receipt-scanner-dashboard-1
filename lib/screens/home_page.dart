import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customCardColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F5F5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 34),
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

          const SizedBox(height: 20),
          // Receipts Section
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
                    child: index == 0
                        ? Card(
                            elevation: 2,
                            color: customCardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.camera, size: 32, color: isDark ? Colors.white70 : Colors.black54),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Upload receipt',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ReceiptCard(index: index - 1),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          // Analytics Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Text(
              'Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Card(
              elevation: 2,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get insights into your spending habits. View charts and trends to manage your budget more effectively.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to analytics page
                        },
                        child: const Text('View Analytics'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ReceiptCard extends StatelessWidget {
  final int index;

  const ReceiptCard({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final monthIndex = (6 + index) % 12;
    final day = 25 + index;

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${months[monthIndex]} $day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '£${(100 + index * 10).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Store',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF797C85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
