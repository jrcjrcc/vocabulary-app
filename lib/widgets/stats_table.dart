import 'package:flutter/material.dart';
import '../models/word.dart';
import '../utils/theme.dart';

class StatsTable extends StatelessWidget {
  final List<Word> words;

  const StatsTable({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('暂无数据，开始学习吧！',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('排名', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('单词', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('释义', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('不会次数', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: List.generate(words.length, (i) {
          final w = words[i];
          return DataRow(cells: [
            DataCell(Text('${i + 1}')),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (w.phonetic.isNotEmpty)
                  Text(w.phonetic, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            )),
            DataCell(SizedBox(width: 200, child: Text(w.definition, overflow: TextOverflow.ellipsis))),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.unknownRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${w.failCount}',
                style: const TextStyle(color: AppTheme.unknownRed, fontWeight: FontWeight.bold),
              ),
            )),
          ]);
        }),
      ),
    );
  }
}
