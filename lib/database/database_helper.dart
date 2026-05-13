import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../models/session.dart';
import '../models/session_word.dart';
import '../models/source_info.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocab.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            phonetic TEXT DEFAULT '',
            definition TEXT NOT NULL,
            example TEXT DEFAULT '',
            language TEXT NOT NULL,
            source TEXT NOT NULL,
            fail_count INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            language TEXT NOT NULL,
            source TEXT NOT NULL,
            total_words INTEGER DEFAULT 0,
            known_words INTEGER DEFAULT 0,
            unknown_words INTEGER DEFAULT 0,
            config_path TEXT DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS session_words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            word_id INTEGER NOT NULL,
            is_known INTEGER DEFAULT 0,
            fail_count_in_session INTEGER DEFAULT 0,
            FOREIGN KEY (session_id) REFERENCES sessions(id),
            FOREIGN KEY (word_id) REFERENCES words(id)
          )
        ''');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_words_source ON words(source)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_words_language ON words(language)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_session_words_session ON session_words(session_id)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_session_words_word ON session_words(word_id)');
      },
    );
  }

  // --- Word operations ---

  Future<int> countWordsBySource(String source) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM words WHERE source = ?',
      [source],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countWordsByLanguage(String language) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM words WHERE language = ?',
      [language],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Word>> getWordsBySource(String source, {int? limit}) async {
    final db = await database;
    final query = limit != null
        ? 'SELECT * FROM words WHERE source = ? ORDER BY RANDOM() LIMIT $limit'
        : 'SELECT * FROM words WHERE source = ? ORDER BY RANDOM()';
    final results = await db.rawQuery(query, [source]);
    return results.map((m) => Word.fromMap(m)).toList();
  }

  Future<Word?> getWordById(int wordId) async {
    final db = await database;
    final results = await db.rawQuery('SELECT * FROM words WHERE id = ?', [wordId]);
    if (results.isEmpty) return null;
    return Word.fromMap(results.first);
  }

  Future<void> updateWordFailCount(int wordId, {int increment = 1}) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE words SET fail_count = fail_count + ? WHERE id = ?',
      [increment, wordId],
    );
  }

  Future<void> insertWord(Map<String, dynamic> word) async {
    final db = await database;
    await db.rawInsert(
      'INSERT INTO words (word, phonetic, definition, example, language, source) VALUES (?, ?, ?, ?, ?, ?)',
      [word['word'], word['phonetic'] ?? '', word['definition'], word['example'] ?? '', word['language'], word['source']],
    );
  }

  Future<void> insertWordsBatch(List<Map<String, dynamic>> words) async {
    final db = await database;
    final batch = db.batch();
    for (final w in words) {
      batch.rawInsert(
        'INSERT INTO words (word, phonetic, definition, example, language, source) VALUES (?, ?, ?, ?, ?, ?)',
        [w['word'], w['phonetic'] ?? '', w['definition'], w['example'] ?? '', w['language'], w['source']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getWordCountBySource() async {
    final db = await database;
    return db.rawQuery(
      'SELECT source, COUNT(*) as cnt FROM words GROUP BY source ORDER BY source',
    );
  }

  Future<List<Word>> getAllWords({String? source}) async {
    final db = await database;
    final query = source != null
        ? 'SELECT * FROM words WHERE source = ? ORDER BY fail_count DESC, word'
        : 'SELECT * FROM words ORDER BY fail_count DESC, word';
    final params = source != null ? [source] : <String>[];
    final results = await db.rawQuery(query, params);
    return results.map((m) => Word.fromMap(m)).toList();
  }

  // --- Session operations ---

  Future<int> createSession(String language, String source, int totalWords) async {
    final db = await database;
    final result = await db.rawInsert(
      'INSERT INTO sessions (language, source, total_words) VALUES (?, ?, ?)',
      [language, source, totalWords],
    );
    return result;
  }

  Future<void> updateSession(int sessionId, int knownWords, int unknownWords, String configPath) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sessions SET known_words = ?, unknown_words = ?, config_path = ? WHERE id = ?',
      [knownWords, unknownWords, configPath, sessionId],
    );
  }

  Future<void> insertSessionWords(int sessionId, List<Map<String, dynamic>> wordResults) async {
    final db = await database;
    final batch = db.batch();
    for (final w in wordResults) {
      batch.rawInsert(
        'INSERT INTO session_words (session_id, word_id, is_known, fail_count_in_session) VALUES (?, ?, ?, ?)',
        [sessionId, w['word_id'], w['is_known'], w['fail_count']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Session>> getAllSessions() async {
    final db = await database;
    final results = await db.rawQuery('SELECT * FROM sessions ORDER BY created_at DESC');
    return results.map((m) => Session.fromMap(m)).toList();
  }

  Future<Session?> getSessionById(int sessionId) async {
    final db = await database;
    final results = await db.rawQuery('SELECT * FROM sessions WHERE id = ?', [sessionId]);
    if (results.isEmpty) return null;
    return Session.fromMap(results.first);
  }

  Future<List<Map<String, dynamic>>> getSessionWords(int sessionId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT sw.*, w.word, w.phonetic, w.definition, w.example, w.language, w.source
      FROM session_words sw
      JOIN words w ON w.id = sw.word_id
      WHERE sw.session_id = ?
    ''', [sessionId]);
  }

  // --- Statistics ---

  Future<List<Word>> getStatistics({String? source}) async {
    final db = await database;
    final query = source != null
        ? 'SELECT * FROM words WHERE source = ? AND fail_count > 0 ORDER BY fail_count DESC, word LIMIT 200'
        : 'SELECT * FROM words WHERE fail_count > 0 ORDER BY fail_count DESC, word LIMIT 200';
    final params = source != null ? [source] : <String>[];
    final results = await db.rawQuery(query, params);
    return results.map((m) => Word.fromMap(m)).toList();
  }

  Future<List<SourceInfo>> getSourceInfo() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT language, source, COUNT(*) as count
      FROM words
      GROUP BY source
      ORDER BY language, source
    ''');
    return results.map((m) => SourceInfo.fromMap(m)).toList();
  }

  Future<int> getWordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM words');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteAllWords() async {
    final db = await database;
    await db.delete('words');
  }
}
