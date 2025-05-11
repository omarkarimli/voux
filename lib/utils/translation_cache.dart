class TranslationCache {
  final _cache = <String, Map<String, String>>{};

  String? get(String originalText, String languageCode) {
    return _cache[originalText]?[languageCode];
  }

  void set(String originalText, String languageCode, String translatedText) {
    _cache[originalText] ??= {};
    _cache[originalText]![languageCode] = translatedText;
  }
}