class SourceInfo {
  final String source;
  final String language;
  final int count;

  SourceInfo({
    required this.source,
    required this.language,
    required this.count,
  });

  factory SourceInfo.fromMap(Map<String, dynamic> m) => SourceInfo(
        source: m['source'] as String,
        language: m['language'] as String,
        count: m['count'] as int,
      );
}
