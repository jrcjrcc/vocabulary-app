class Word {
  final int? id;
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final String language;
  final String source;
  final int failCount;

  Word({
    this.id,
    required this.word,
    this.phonetic = '',
    required this.definition,
    this.example = '',
    required this.language,
    required this.source,
    this.failCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'word': word,
        'phonetic': phonetic,
        'definition': definition,
        'example': example,
        'language': language,
        'source': source,
        'fail_count': failCount,
      };

  factory Word.fromMap(Map<String, dynamic> m) => Word(
        id: m['id'] as int?,
        word: m['word'] as String,
        phonetic: (m['phonetic'] as String?) ?? '',
        definition: m['definition'] as String,
        example: (m['example'] as String?) ?? '',
        language: m['language'] as String,
        source: m['source'] as String,
        failCount: (m['fail_count'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'definition': definition,
        'example': example,
        'fail_count': failCount,
      };
}
