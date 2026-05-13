import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ConfigModal extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final bool readOnly;
  final Future<bool> Function(String content)? onSave;

  const ConfigModal({
    super.key,
    required this.title,
    required this.data,
    this.readOnly = false,
    this.onSave,
  });

  @override
  State<ConfigModal> createState() => _ConfigModalState();
}

class _ConfigModalState extends State<ConfigModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(widget.data),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: TextField(
          controller: _controller,
          readOnly: widget.readOnly,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (!widget.readOnly)
          ElevatedButton(
            onPressed: () async {
              if (widget.onSave != null) {
                final success = await widget.onSave!(_controller.text);
                if (success && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
