// lib/viewmodels/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/routes/app_router.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.read(storageServiceProvider);
  final dio = DioClient.build(storage, onUnauthorized: redirectToLogin);
  return ApiService(dio);
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiServiceProvider), ref.read(storageServiceProvider)),
);

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(ref.read(apiServiceProvider)),
);

