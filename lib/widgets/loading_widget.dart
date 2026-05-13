import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = '加载中...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
