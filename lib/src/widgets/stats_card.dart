import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse Card theming from main.dart
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? Colors.blue).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
