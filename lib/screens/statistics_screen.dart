import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/stats_table.dart';
import '../widgets/loading_widget.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _selectedSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StatisticsProvider>();
      provider.loadSources();
      provider.loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: const InputDecoration(
                  labelText: '选择词库',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('全部词库')),
                  ...provider.sources.map((s) => DropdownMenuItem(
                        value: s.source,
                        child: Text(sourceLabels[s.source] ?? s.source),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedSource = val);
                  provider.loadStatistics(source: val);
                },
              ),
            ),
            Expanded(
              child: provider.loading
                  ? const LoadingWidget()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StatsTable(words: provider.words),
                    ),
            ),
          ],
        );
      },
    );
  }
}
