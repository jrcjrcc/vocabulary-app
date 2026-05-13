import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ConfigListItem extends StatelessWidget {
  final String filename;
  final int wordCount;
  final String source;
  final String date;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const ConfigListItem({
    super.key,
    required this.filename,
    required this.wordCount,
    required this.source,
    required this.date,
    required this.onView,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filename, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '$wordCount 词 | 来源: $source${date.isNotEmpty ? ' | $date' : ''}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.visibility, size: 20), onPressed: onView),
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.share, size: 20), onPressed: onShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
