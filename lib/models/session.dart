class Session {
  final int? id;
  final String language;
  final String source;
  final int totalWords;
  final int knownWords;
  final int unknownWords;
  final String? configPath;
  final String createdAt;

  Session({
    this.id,
    required this.language,
    required this.source,
    required this.totalWords,
    this.knownWords = 0,
    this.unknownWords = 0,
    this.configPath,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
        'id': id,
        'language': language,
        'source': source,
        'total_words': totalWords,
        'known_words': knownWords,
        'unknown_words': unknownWords,
        'config_path': configPath,
        'created_at': createdAt,
      };

  factory Session.fromMap(Map<String, dynamic> m) => Session(
        id: m['id'] as int?,
        language: m['language'] as String,
        source: m['source'] as String,
        totalWords: m['total_words'] as int,
        knownWords: (m['known_words'] as int?) ?? 0,
        unknownWords: (m['unknown_words'] as int?) ?? 0,
        configPath: m['config_path'] as String?,
        createdAt: m['created_at'] as String?,
      );
}
