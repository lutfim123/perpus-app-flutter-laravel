// lib/repositories/book_repository.dart
import '../core/constants/api_constants.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';

class BookRepository {
  final ApiService _api;
  BookRepository(this._api);

  Future<BookPage> getBooks({String? search, int page = 1}) async {
    final res = await _api.get(ApiConstants.books, params: {
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'per_page': ApiConstants.perPage,
    });
    return BookPage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookModel> createBook(Map<String, dynamic> payload) async {
    final res = await _api.post(ApiConstants.books, payload);
    return BookModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<BookModel> updateBook(int id, Map<String, dynamic> payload) async {
    final res = await _api.put('${ApiConstants.books}/$id', payload);
    return BookModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBook(int id) => _api.delete('${ApiConstants.books}/$id');
}

