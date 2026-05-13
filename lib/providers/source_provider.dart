import 'package:flutter/foundation.dart';
import '../models/source_info.dart';
import '../database/database_helper.dart';

class SourceProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<SourceInfo> _sources = [];
  bool _loading = false;

  List<SourceInfo> get sources => _sources;
  bool get loading => _loading;

  Future<void> loadSources() async {
    _loading = true;
    notifyListeners();

    try {
      final rows = await _db.getSourceInfo();
      _sources = rows;
    } catch (e) {
      _sources = [];
    }

    _loading = false;
    notifyListeners();
  }
}
