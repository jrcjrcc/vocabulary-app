import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/theme.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final bool revealed;
  final String language;

  const WordCard({
    super.key,
    required this.word,
    required this.revealed,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isJP = language == 'jp';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              word.word,
              style: TextStyle(
                fontSize: isJP ? 32 : 28,
                fontWeight: FontWeight.bold,
                fontFamily: isJP ? null : null,
              ),
            ),
            if (word.phonetic.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                word.phonetic,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            if (revealed) ...[
              const Divider(height: 32),
              if (word.definition.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    word.definition,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (word.example.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    word.example,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
