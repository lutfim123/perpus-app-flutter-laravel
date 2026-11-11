// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';

  // Cache in-memory: interceptor membaca token di SETIAP request,
  // jadi hindari bolak-balik ke SharedPreferences.
  SharedPreferences? _prefs;
  String? _token;
  bool _loaded = false;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    _token = token;
    _loaded = true;
    await (await _instance).setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    if (!_loaded) {
      _token = (await _instance).getString(_tokenKey);
      _loaded = true;
    }
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    _loaded = true;
    await (await _instance).remove(_tokenKey);
  }
}

