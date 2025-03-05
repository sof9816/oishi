import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the keys used in shared preferences.
enum PreferenceKey {
  token,
}

/// Extension on PreferenceKey to get the string value of the enum.
extension PreferenceKeyExtension on PreferenceKey {
  String get keyString => toString().split('.').last;
}

/// Class to manage shared preferences with generic methods.
class AppPreferences {
  /// Saves a value of generic type [T] to shared preferences.
  static Future<void> saveValue<T>(String key, T value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      throw Exception('Unsupported type');
    }
  }

  /// Retrieves a value of generic type [T] from shared preferences.
  static Future<T?> getValue<T>(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    } else {
      return null;
    }
  }

  /// Removes a value from shared preferences.
  static Future<void> removeValue(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clears all values from shared preferences.
  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
