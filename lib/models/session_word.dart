class SessionWord {
  final int? id;
  final int sessionId;
  final int wordId;
  final bool isKnown;
  final int failCount;

  SessionWord({
    this.id,
    required this.sessionId,
    required this.wordId,
    this.isKnown = false,
    this.failCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'word_id': wordId,
        'is_known': isKnown ? 1 : 0,
        'fail_count': failCount,
      };

  factory SessionWord.fromMap(Map<String, dynamic> m) => SessionWord(
        id: m['id'] as int?,
        sessionId: m['session_id'] as int,
        wordId: m['word_id'] as int,
        isKnown: (m['is_known'] as int) == 1,
        failCount: (m['fail_count'] as int?) ?? 0,
      );
}
