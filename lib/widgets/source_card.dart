import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/source_info.dart';

class SourceCard extends StatelessWidget {
  final SourceInfo source;
  final VoidCallback onTap;

  const SourceCard({super.key, required this.source, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String label;
    switch (source.source) {
      case 'en_cet6': label = '六级词汇'; break;
      case 'jp_n5': label = 'N5'; break;
      case 'jp_n4': label = 'N4'; break;
      case 'jp_n3': label = 'N3'; break;
      case 'jp_n2': label = 'N2'; break;
      case 'jp_n1': label = 'N1'; break;
      case 'es_basic': label = '基础词汇'; break;
      default: label = source.source;
    }

    final langLabel = _langName(source.language);
    final color = AppTheme.badgeFor(source.language);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${source.count} 词', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(langLabel, style: TextStyle(color: color, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _langName(String lang) {
    switch (lang) {
      case 'en': return '英语';
      case 'jp': return '日语';
      case 'es': return '西班牙语';
      case 'fr': return '法语';
      default: return lang;
    }
  }
}
