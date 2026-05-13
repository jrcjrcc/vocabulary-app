import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/session.dart';
import '../database/database_helper.dart';

class ConfigProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Session> _sessions = [];
  List<Map<String, dynamic>> _configFiles = [];
  bool _loading = false;

  List<Session> get sessions => _sessions;
  List<Map<String, dynamic>> get configFiles => _configFiles;
  bool get loading => _loading;

  Future<void> loadSessions() async {
    _loading = true;
    notifyListeners();

    try {
      _sessions = await _db.getAllSessions();
    } catch (e) {
      _sessions = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadConfigFiles() async {
    _loading = true;
    notifyListeners();

    try {
      final dir = await _getConfigDir();
      if (!await dir.exists()) {
        _configFiles = [];
      } else {
        final files = await dir.list().toList();
        _configFiles = [];
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            try {
              final content = await file.readAsString();
              final data = json.decode(content);
              _configFiles.add({
                'filename': file.path.split('/').last,
                'date': data['date'] ?? '',
                'source': data['source'] ?? '',
                'word_count': data['total_words'] ?? 0,
              });
            } catch (e) {
              // skip invalid files
            }
          }
        }
      }
    } catch (e) {
      _configFiles = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> readConfig(String filename) async {
    try {
      final dir = await _getConfigDir();
      final file = File('${dir.path}/$filename');
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateConfig(String filename, Map<String, dynamic> content) async {
    try {
      final dir = await _getConfigDir();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(json.encode(content));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> exportSessionAsConfig(int sessionId) async {
    try {
      final session = await _db.getSessionById(sessionId);
      if (session == null) return null;

      final sessionWords = await _db.getSessionWords(sessionId);
      final words = sessionWords.map((w) => {
        'word': w['word'],
        'phonetic': w['phonetic'] ?? '',
        'definition': w['definition'] ?? '',
        'example': w['example'] ?? '',
        'is_known': w['is_known'] == 1,
        'fail_count_in_session': w['fail_count_in_session'] ?? 0,
        'total_fail_count': 0,
      }).toList();

      final config = {
        'session_id': sessionId,
        'language': session.language,
        'source': session.source,
        'date': DateTime.now().toIso8601String(),
        'total_words': session.totalWords,
        'known_words': session.knownWords,
        'unknown_words': session.unknownWords,
        'words': words,
      };

      final dir = await _getConfigDir();
      if (!await dir.exists()) await dir.create(recursive: true);
      final filename = 'session_${sessionId}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(json.encode(config));

      await loadConfigFiles();
      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> importConfig(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = json.decode(content);

      if (data is Map<String, dynamic> && data.containsKey('words')) {
        final dir = await _getConfigDir();
        if (!await dir.exists()) await dir.create(recursive: true);
        final filename = 'imported_${DateTime.now().millisecondsSinceEpoch}.json';
        final dest = File('${dir.path}/$filename');
        await dest.writeAsString(content);
        await loadConfigFiles();
        return data;
      } else if (data is List) {
        final config = {
          'words': data,
          'source': 'imported',
          'language': 'unknown',
          'date': DateTime.now().toIso8601String(),
        };
        final dir = await _getConfigDir();
        if (!await dir.exists()) await dir.create(recursive: true);
        final filename = 'imported_${DateTime.now().millisecondsSinceEpoch}.json';
        final dest = File('${dir.path}/$filename');
        await dest.writeAsString(json.encode(config));
        await loadConfigFiles();
        return config;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> pickAndImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        await importConfig(result.files.single.path!);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> shareConfig(String filename) async {
    try {
      final dir = await _getConfigDir();
      final file = File('${dir.path}/$filename');
      if (await file.exists()) {
        await Share.shareXFiles([XFile(file.path)], text: filename);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<Directory> _getConfigDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/configs');
  }
}
