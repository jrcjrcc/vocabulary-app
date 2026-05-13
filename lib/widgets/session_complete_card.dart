import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SessionCompleteCard extends StatelessWidget {
  final int totalWords;
  final int knownWords;
  final int unknownWords;
  final VoidCallback onContinue;
  final VoidCallback onViewStats;

  const SessionCompleteCard({
    super.key,
    required this.totalWords,
    required this.knownWords,
    required this.unknownWords,
    required this.onContinue,
    required this.onViewStats,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('本轮完成！',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(label: '总计', value: totalWords.toString(), color: AppTheme.textPrimary),
                  _StatItem(label: '已掌握', value: knownWords.toString(), color: AppTheme.knownGreen),
                  _StatItem(label: '待复习', value: unknownWords.toString(), color: AppTheme.unknownRed),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    child: const Text('继续学习'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onViewStats,
                    child: const Text('查看统计'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
