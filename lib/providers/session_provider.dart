import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/learning_service.dart';

class SessionProvider extends ChangeNotifier {
  LearningService? _service;
  Word? _currentWord;
  Map<String, int> _progress = {};
  bool _active = false;
  bool _revealed = false;
  bool _complete = false;
  SessionResult? _result;
  String? _error;

  LearningService? get service => _service;
  Word? get currentWord => _currentWord;
  Map<String, int> get progress => _progress;
  bool get active => _active;
  bool get revealed => _revealed;
  bool get complete => _complete;
  SessionResult? get result => _result;
  String? get error => _error;

  Future<bool> startSession(String source, String language) async {
    _active = true;
    _complete = false;
    _revealed = false;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _service = LearningService();
      await _service!.start(source, language);
      _currentWord = _service!.currentWord;
      _progress = _service!.getProgress();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '启动失败: $e';
      _active = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markKnown() async {
    if (_revealed || _currentWord == null || _service == null) return;
    _revealed = true;
    notifyListeners();

    try {
      _currentWord = await _service!.markKnown(_currentWord!.id!);
      _progress = _service!.getProgress();

      if (_service!.isComplete) {
        _result = await _service!.endSession();
        _complete = true;
        _active = false;
      } else {
        _revealed = false;
      }
      notifyListeners();
    } catch (e) {
      _error = '操作失败: $e';
      notifyListeners();
    }
  }

  Future<void> markUnknown() async {
    if (_revealed || _currentWord == null || _service == null) return;
    _revealed = true;
    notifyListeners();
  }

  Future<void> confirmUnknown() async {
    if (_currentWord == null || _service == null) return;

    try {
      _currentWord = await _service!.markUnknown(_currentWord!.id!);
      _progress = _service!.getProgress();

      if (_service!.isComplete) {
        _result = await _service!.endSession();
        _complete = true;
        _active = false;
      } else {
        _revealed = false;
      }
      notifyListeners();
    } catch (e) {
      _error = '操作失败: $e';
      notifyListeners();
    }
  }

  void reset() {
    _service = null;
    _currentWord = null;
    _progress = {};
    _active = false;
    _revealed = false;
    _complete = false;
    _result = null;
    _error = null;
    notifyListeners();
  }
}
