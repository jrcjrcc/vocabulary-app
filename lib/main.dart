import 'package:flutter/material.dart';
import 'app.dart';
import 'services/vocab_loader_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 首次启动时从 assets 导入词库到 SQLite（已导入则跳过）
  final loader = VocabLoaderService();
  await loader.loadAll();

  runApp(const VocabularyApp());
}
