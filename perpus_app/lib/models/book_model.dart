// lib/models/book_model.dart
int _toInt(Object? v) => v is num ? v.toInt() : int.parse(v.toString());

class BookModel {
  final int id;
  final String title;
  final String author;
  final String? publisher;
  final String isbn;
  final int publishedYear;
  final int stock;
  final String? description;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.publisher,
    required this.isbn,
    required this.publishedYear,
    required this.stock,
    this.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> j) => BookModel(
        id: _toInt(j['id']),
        title: j['title'] as String,
        author: j['author'] as String,
        publisher: j['publisher'] as String?,
        isbn: j['isbn'] as String,
        publishedYear: _toInt(j['published_year']),
        stock: _toInt(j['stock']),
        description: j['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'publisher': publisher,
        'isbn': isbn,
        'published_year': publishedYear,
        'stock': stock,
        'description': description,
      };
}

/// Satu halaman hasil `GET /api/books` (Laravel paginator: data + meta).
class BookPage {
  final List<BookModel> books;
  final int currentPage;
  final int lastPage;
  final int total;

  const BookPage({
    required this.books,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory BookPage.fromJson(Map<String, dynamic> json) {
    final books = (json['data'] as List)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>?;
    return BookPage(
      books: books,
      currentPage: meta == null ? 1 : _toInt(meta['current_page']),
      lastPage: meta == null ? 1 : _toInt(meta['last_page']),
      total: meta == null ? books.length : _toInt(meta['total']),
    );
  }
}

