import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/source_provider.dart';
import 'providers/session_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/config_provider.dart';
import 'screens/sources_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/config_screen.dart';
import 'utils/theme.dart';

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SourceProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
      ],
      child: MaterialApp(
        title: '背单词',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('背单词'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.library_books), text: '词库'),
              Tab(icon: Icon(Icons.school), text: '学习'),
              Tab(icon: Icon(Icons.bar_chart), text: '统计'),
              Tab(icon: Icon(Icons.settings), text: '配置'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SourcesScreen(),
            LearningScreen(),
            StatisticsScreen(),
            ConfigScreen(),
          ],
        ),
      ),
    );
  }
}
