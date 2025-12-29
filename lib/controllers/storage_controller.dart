import 'package:shared_preferences/shared_preferences.dart';

class StorageController {
  static final instance = StorageController();
  String languageCode = "languageCode";
  String countryCode = "countryCode";
  String lng = "language";

  Future<String?> getLang() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(lng);
  }

  Future<void> setLang(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(lng, value);
  }

  Future<void> setLanguage(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(languageCode, value);
  }

  Future<String?> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageCode);
  }

  Future<void> setCountryCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(countryCode, value);
  }

  Future<String?> getCountryCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(countryCode);
  }

  // Generic methods for API integration
  Future<void> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  Future<void> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
