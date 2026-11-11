// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../../services/storage_service.dart';
import '../constants/api_constants.dart';

class DioClient {
  /// [onUnauthorized] dipanggil saat server membalas 401 untuk request yang
  /// memakai token (token kedaluwarsa / dicabut) → arahkan user ke login.
  static Dio build(StorageService storage, {void Function()? onUnauthorized}) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final hadToken = err.requestOptions.headers.containsKey('Authorization');
        if (err.response?.statusCode == 401 && hadToken) {
          await storage.clearToken();
          // Jangan redirect saat logout: user memang sedang keluar.
          if (err.requestOptions.path != ApiConstants.logout) onUnauthorized?.call();
        }
        handler.next(err);
      },
    ));

    return dio;
  }
}

