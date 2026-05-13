import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProgressBarWidget extends StatelessWidget {
  final int done;
  final int total;
  final int percent;

  const ProgressBarWidget({
    super.key,
    required this.done,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [AppTheme.progressStart, AppTheme.progressEnd],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$done / $total',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
