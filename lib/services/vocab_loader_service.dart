import 'dart:convert';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';

class VocabLoaderService {
  final DatabaseHelper _db = DatabaseHelper();

  static const Map<String, String> _assetFiles = {
    'en_cet6': 'assets/vocab/en_cet6.json',
    'es_basic': 'assets/vocab/es_basic.json',
    'jp_n5': 'assets/vocab/jp_n5.json',
    'jp_n4': 'assets/vocab/jp_n4.json',
    'jp_n3': 'assets/vocab/jp_n3.json',
    'jp_n2': 'assets/vocab/jp_n2.json',
    'jp_n1': 'assets/vocab/jp_n1.json',
  };

  List<String> get availableSources => _assetFiles.keys.toList();

  Future<Map<String, int>> loadAll() async {
    final results = <String, int>{};

    for (final entry in _assetFiles.entries) {
      final source = entry.key;
      final assetPath = entry.value;

      final existing = await _db.countWordsBySource(source);
      if (existing > 0) {
        results[source] = existing;
        continue;
      }

      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final List<dynamic> words = json.decode(jsonString);
        final batch = words.map<Map<String, dynamic>>((w) => {
          'word': w['word'],
          'phonetic': w['phonetic'] ?? '',
          'definition': w['definition'] ?? '',
          'example': w['example'] ?? '',
          'language': w['language'] ?? source.split('_').first,
          'source': source,
        }).toList();

        await _db.insertWordsBatch(batch);
        results[source] = batch.length;
      } catch (e) {
        results[source] = -1;
      }
    }

    return results;
  }

  Future<bool> isLoaded(String source) async {
    final count = await _db.countWordsBySource(source);
    return count > 0;
  }
}
