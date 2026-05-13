import 'dart:math';
import '../models/word.dart';
import '../database/database_helper.dart';

class LearningService {
  final DatabaseHelper _db = DatabaseHelper();
  final Random _random = Random();
  final int cycleSize;

  late String _source;
  late String _language;
  late int _sessionId;
  List<Word> _words = [];
  List<Word> _queue = [];
  List<Word> _reviewPool = [];
  final Map<int, SessionWordData> _sessionWordData = {};
  int _processedCount = 0;
  bool _ended = false;

  LearningService({this.cycleSize = 25});

  bool get isComplete => _ended;
  String get source => _source;
  String get language => _language;

  Future<void> start(String source, String language) async {
    _source = source;
    _language = language;
    _processedCount = 0;
    _ended = false;
    _reviewPool.clear();
    _sessionWordData.clear();

    _words = await _db.getWordsBySource(source, limit: cycleSize);
    _queue = List.from(_words);

    for (final w in _words) {
      _sessionWordData[w.id!] = SessionWordData(isKnown: false, failCount: 0);
    }

    _sessionId = await _db.createSession(language, source, _words.length);
  }

  Word? get currentWord => _queue.isNotEmpty ? _queue.first : null;

  Future<Word?> markKnown(int wordId) async {
    if (_sessionWordData.containsKey(wordId)) {
      _sessionWordData[wordId]!.isKnown = true;
    }
    _dequeueWord(wordId);
    _maybeInsertReview();
    return currentWord;
  }

  Future<Word?> markUnknown(int wordId) async {
    if (_sessionWordData.containsKey(wordId)) {
      _sessionWordData[wordId]!.failCount++;
    }
    await _db.updateWordFailCount(wordId);

    final word = _dequeueWord(wordId);
    if (word != null) {
      _reviewPool.add(word);
    }
    _maybeInsertReview();
    return currentWord;
  }

  Word? _dequeueWord(int wordId) {
    if (_queue.isNotEmpty && _queue.first.id == wordId) {
      final word = _queue.removeAt(0);
      _processedCount++;
      return word;
    }
    return null;
  }

  void _maybeInsertReview() {
    if (_reviewPool.isEmpty) return;
    if (_processedCount >= cycleSize) return;

    if (_queue.isEmpty) {
      _queue.add(_reviewPool.removeAt(0));
      return;
    }

    final idx = _random.nextInt(_reviewPool.length);
    _queue.add(_reviewPool.removeAt(idx));
  }

  void _checkComplete() {
    if (_processedCount >= cycleSize && _queue.isEmpty) {
      _ended = true;
    }
  }

  Map<String, int> getProgress() {
    final total = _sessionWordData.length;
    final done = _processedCount;
    return {
      'total': total,
      'done': done > total ? total : done,
      'remaining': (total > done ? total - done : 0) + _queue.length,
      'percent': total > 0 ? ((done > total ? total : done) * 100 ~/ total) : 0,
    };
  }

  Future<SessionResult> endSession() async {
    _ended = true;
    int known = 0, unknown = 0;
    for (final data in _sessionWordData.values) {
      if (data.isKnown) {
        known++;
      } else {
        unknown++;
      }
    }

    await _db.insertSessionWords(
      _sessionId,
      _sessionWordData.entries.map((e) => {
        'word_id': e.key,
        'is_known': e.value.isKnown ? 1 : 0,
        'fail_count': e.value.failCount,
      }).toList(),
    );

    await _db.updateSession(_sessionId, known, unknown, '');

    return SessionResult(
      sessionId: _sessionId,
      totalWords: _sessionWordData.length,
      knownWords: known,
      unknownWords: unknown,
      words: _words.map((w) {
        final sw = _sessionWordData[w.id!]!;
        return WordResult(
          word: w.word,
          phonetic: w.phonetic,
          definition: w.definition,
          example: w.example,
          isKnown: sw.isKnown,
          failCountInSession: sw.failCount,
          totalFailCount: w.failCount,
        );
      }).toList(),
    );
  }
}

class SessionWordData {
  bool isKnown;
  int failCount;

  SessionWordData({required this.isKnown, this.failCount = 0});
}

class SessionResult {
  final int sessionId;
  final int totalWords;
  final int knownWords;
  final int unknownWords;
  final List<WordResult> words;

  SessionResult({
    required this.sessionId,
    required this.totalWords,
    required this.knownWords,
    required this.unknownWords,
    required this.words,
  });

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'total_words': totalWords,
        'known_words': knownWords,
        'unknown_words': unknownWords,
        'words': words.map((w) => w.toJson()).toList(),
      };
}

class WordResult {
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final bool isKnown;
  final int failCountInSession;
  final int totalFailCount;

  WordResult({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.isKnown,
    required this.failCountInSession,
    required this.totalFailCount,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'definition': definition,
        'example': example,
        'is_known': isKnown,
        'fail_count_in_session': failCountInSession,
        'total_fail_count': totalFailCount,
      };
}
