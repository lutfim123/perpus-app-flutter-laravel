// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../core/network/api_exception.dart';

/// Pembungkus Dio: semua error dikonversi menjadi [ApiException]
/// sehingga ViewModel cukup menangkap satu jenis exception.
class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  Future<Response> post(String path, [Map<String, dynamic>? data]) =>
      _guard(() => _dio.post(path, data: data));

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _guard(() => _dio.get(path, queryParameters: params));

  Future<Response> put(String path, Map<String, dynamic> data) =>
      _guard(() => _dio.put(path, data: data));

  Future<Response> delete(String path) => _guard(() => _dio.delete(path));

  Future<Response> _guard(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

