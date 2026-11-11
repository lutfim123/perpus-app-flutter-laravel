// lib/viewmodels/book_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';
import 'providers.dart';

class BookState {
  final List<BookModel> books;
  final bool loading; // memuat halaman pertama
  final bool loadingMore; // memuat halaman berikutnya
  final String? error; // error saat memuat daftar
  final String search;
  final int page;
  final int lastPage;
  final int total;

  const BookState({
    this.books = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.search = '',
    this.page = 0,
    this.lastPage = 1,
    this.total = 0,
  });

  bool get hasMore => page < lastPage;

  BookState copyWith({
    List<BookModel>? books,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
    String? search,
    int? page,
    int? lastPage,
    int? total,
  }) =>
      BookState(
        books: books ?? this.books,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
        search: search ?? this.search,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        total: total ?? this.total,
      );
}

class BookNotifier extends Notifier<BookState> {
  int _requestId = 0;

  @override
  BookState build() => const BookState();

  BookRepository get _repo => ref.read(bookRepositoryProvider);

  /// Muat ulang dari halaman 1. Tanpa [search] → pakai kata kunci terakhir.
  Future<void> load({String? search}) async {
    final query = (search ?? state.search).trim();
    final id = ++_requestId; // abaikan respons lama jika user mencari lagi
    state = state.copyWith(loading: true, loadingMore: false, clearError: true, search: query);
    try {
      final result = await _repo.getBooks(search: query, page: 1);
      if (id != _requestId) return;
      state = BookState(
        books: result.books,
        search: query,
        page: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
      );
    } on ApiException catch (e) {
      if (id != _requestId) return;
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  /// Muat halaman berikutnya (infinite scroll).
  Future<String?> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return null;
    final id = _requestId;
    state = state.copyWith(loadingMore: true);
    try {
      final result = await _repo.getBooks(search: state.search, page: state.page + 1);
      if (id != _requestId) return null;
      final known = state.books.map((b) => b.id).toSet();
      state = state.copyWith(
        books: [...state.books, ...result.books.where((b) => !known.contains(b.id))],
        loadingMore: false,
        page: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
      );
      return null;
    } on ApiException catch (e) {
      if (id == _requestId) state = state.copyWith(loadingMore: false);
      return e.message;
    }
  }

  /// Return null jika sukses, atau [ApiException] (berisi error per-field) jika gagal.
  Future<ApiException?> create(Map<String, dynamic> payload) async {
    try {
      final book = await _repo.createBook(payload);
      state = state.copyWith(books: [book, ...state.books], total: state.total + 1);
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }

  Future<ApiException?> update(int id, Map<String, dynamic> payload) async {
    try {
      final updated = await _repo.updateBook(id, payload);
      state = state.copyWith(
        books: state.books.map((b) => b.id == id ? updated : b).toList(),
      );
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }

  Future<String?> delete(int id) async {
    try {
      await _repo.deleteBook(id);
    } on ApiException catch (e) {
      if (e.statusCode != 404) return e.message;
      // 404: sudah terhapus di server → tetap hapus dari daftar lokal
    }
    state = state.copyWith(
      books: state.books.where((b) => b.id != id).toList(),
      total: state.total > 0 ? state.total - 1 : 0,
    );
    return null;
  }

  /// Bersihkan data saat logout agar user lain tidak melihat cache lama.
  void reset() {
    _requestId++;
    state = const BookState();
  }
}

final bookProvider = NotifierProvider<BookNotifier, BookState>(BookNotifier.new);

