import 'package:hive/hive.dart';

class CacheHelper {
  static late Box _box;

  /// Init Hive box
  static Future<void> init() async {
    _box = await Hive.openBox('app_cache');
  }

  /// Save any type
  static Future<void> putData({
    required String key,
    required dynamic value,
  }) async {
    await _box.put(key, value);
  }

  /// Get any type
  static dynamic getData(String key) {
    return _box.get(key);
  }

  /// Boolean helpers (optional)
  static bool? getBool(String key) {
    return _box.get(key);
  }

  static Future<void> putBool({
    required String key,
    required bool value,
  }) async {
    await _box.put(key, value);
  }

  /// Remove key
  static Future<void> removeData({
    required String key,
  }) async {
    await _box.delete(key);
  }

  /// Clear all cache
  static Future<void> clearAll() async {
    await _box.clear();
  }
}
