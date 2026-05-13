import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/config_provider.dart';
import '../widgets/config_list_item.dart';
import '../widgets/config_modal.dart';
import '../widgets/loading_widget.dart';
import '../utils/theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigProvider>().loadConfigFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.pickAndImportFile(),
                      icon: const Icon(Icons.file_upload),
                      label: const Text('导入配置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.loadConfigFiles(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('刷新'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.loading
                  ? const LoadingWidget()
                  : provider.configFiles.isEmpty
                      ? const Center(
                          child: Text('暂无配置文件',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        )
                      : ListView.builder(
                          itemCount: provider.configFiles.length,
                          itemBuilder: (context, i) {
                            final c = provider.configFiles[i];
                            final dateStr = (c['date'] as String?) ?? '';
                            final formattedDate = dateStr.isNotEmpty
                                ? dateStr.substring(0, 10)
                                : '';
                            return ConfigListItem(
                              filename: c['filename'] as String,
                              wordCount: c['word_count'] as int? ?? 0,
                              source: c['source'] as String? ?? '',
                              date: formattedDate,
                              onView: () => _viewConfig(context, provider, c['filename'] as String),
                              onEdit: () => _editConfig(context, provider, c['filename'] as String),
                              onShare: () => provider.shareConfig(c['filename'] as String),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewConfig(BuildContext context, ConfigProvider provider, String filename) async {
    final data = await provider.readConfig(filename);
    if (data == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => ConfigModal(
        title: filename,
        data: data,
        readOnly: true,
      ),
    );
  }

  Future<void> _editConfig(BuildContext context, ConfigProvider provider, String filename) async {
    final data = await provider.readConfig(filename);
    if (data == null || !context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfigModal(
        title: filename,
        data: data,
        readOnly: false,
        onSave: (content) async {
          try {
            final parsed = json.decode(content) as Map<String, dynamic>;
            final ok = await provider.updateConfig(filename, parsed);
            return ok;
          } catch (e) {
            return false;
          }
        },
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
      provider.loadConfigFiles();
    }
  }
}
