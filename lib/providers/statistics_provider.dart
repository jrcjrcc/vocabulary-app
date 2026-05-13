import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/source_info.dart';
import '../database/database_helper.dart';

class StatisticsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Word> _words = [];
  List<SourceInfo> _sources = [];
  bool _loading = false;

  List<Word> get words => _words;
  List<SourceInfo> get sources => _sources;
  bool get loading => _loading;

  Future<void> loadStatistics({String? source}) async {
    _loading = true;
    notifyListeners();

    try {
      _words = await _db.getStatistics(source: source);
    } catch (e) {
      _words = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadSources() async {
    try {
      _sources = await _db.getSourceInfo();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }
}
