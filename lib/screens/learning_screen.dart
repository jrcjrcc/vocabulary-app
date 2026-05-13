import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/session_complete_card.dart';
import '../widgets/loading_widget.dart';
import '../utils/theme.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        if (!provider.active && !provider.complete) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('请先选择词库', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!, style: const TextStyle(color: AppTheme.unknownRed)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.reset(),
                  child: const Text('返回'),
                ),
              ],
            ),
          );
        }

        if (provider.complete) {
          final r = provider.result!;
          return SessionCompleteCard(
            totalWords: r.totalWords,
            knownWords: r.knownWords,
            unknownWords: r.unknownWords,
            onContinue: () {
              provider.reset();
              DefaultTabController.of(context).animateTo(0);
            },
            onViewStats: () {
              DefaultTabController.of(context).animateTo(2);
            },
          );
        }

        final word = provider.currentWord;
        if (word == null) return const LoadingWidget();

        final progress = provider.progress;
        final revealed = provider.revealed;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ProgressBarWidget(
                done: progress['done'] ?? 0,
                total: progress['total'] ?? 0,
                percent: progress['percent'] ?? 0,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: WordCard(
                      word: word,
                      revealed: revealed,
                      language: provider.service?.language ?? '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!revealed)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => provider.markKnown(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.knownGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('会', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => provider.markUnknown(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.unknownRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('不会', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => provider.confirmUnknown(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('继续', style: TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
