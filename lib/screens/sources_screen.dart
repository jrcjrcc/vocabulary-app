import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/source_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/source_card.dart';
import '../widgets/loading_widget.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/source_info.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SourceProvider>().loadSources();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SourceProvider>(
      builder: (context, provider, _) {
        if (provider.loading) return const LoadingWidget();

        final sources = provider.sources;
        final grouped = <String, List<SourceInfo>>{};
        for (final s in sources) {
          grouped.putIfAbsent(s.language, () => []).add(s);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final lang in langOrder)
              if (grouped.containsKey(lang)) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(
                    langNames[lang] ?? lang,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: grouped[lang]!.length,
                  itemBuilder: (context, i) {
                    final s = grouped[lang]![i];
                    return SourceCard(
                      source: s,
                      onTap: () => _startLearning(context, s.source, s.language),
                    );
                  },
                ),
              ],
          ],
        );
      },
    );
  }

  void _startLearning(BuildContext context, String source, String language) {
    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.reset();
    sessionProvider.startSession(source, language).then((ok) {
      if (ok && context.mounted) {
        DefaultTabController.of(context).animateTo(1);
      }
    });
  }
}
