// lib/core/constants/api_constants.dart
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base URL backend `perpus-api` (php artisan serve → port 8000).
  ///
  /// - Web / desktop / iOS simulator : http://localhost:8000/api
  /// - Emulator Android              : http://10.0.2.2:8000/api
  ///   (localhost di emulator = emulator itu sendiri, bukan komputer host)
  /// - HP fisik: jalankan `php artisan serve --host=0.0.0.0` lalu
  ///   `flutter run --dart-define=API_BASE_URL=http://<IP-LAPTOP>:8000/api`
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static const int perPage = 15;

  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String books = '/books';
}

