import 'dart:convert';
import 'package:floor/floor.dart';

class GoogleResultsConverter extends TypeConverter<List<Map<String, String>>, String> {
  @override
  List<Map<String, String>> decode(String databaseValue) {
    final List<dynamic> decoded = jsonDecode(databaseValue);
    return decoded.map((e) => Map<String, String>.from(e)).toList();
  }

  @override
  String encode(List<Map<String, String>> value) {
    return jsonEncode(value);
  }
}
