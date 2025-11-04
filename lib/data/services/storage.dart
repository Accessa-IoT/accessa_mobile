import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setJson(String key, Object value) =>
      _prefs.setString(key, jsonEncode(value));

  static Map<String, dynamic>? getJsonMap(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static List<dynamic>? getJsonList(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    return jsonDecode(s) as List<dynamic>;
  }

  static Future<bool> setBool(String key, bool v) => _prefs.setBool(key, v);
  static bool getBool(String key, {bool def = false}) => _prefs.getBool(key) ?? def;
  static Future<bool> remove(String key) => _prefs.remove(key);
}
