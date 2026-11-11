import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perpus_app/core/network/api_exception.dart';
import 'package:perpus_app/models/book_model.dart';
import 'package:perpus_app/models/user_model.dart';
import 'package:perpus_app/repositories/book_repository.dart';
import 'package:perpus_app/services/api_service.dart';
import 'package:perpus_app/viewmodels/book_vm.dart';
import 'package:perpus_app/viewmodels/providers.dart';
import 'package:perpus_app/views/books/book_detail_view.dart';
import 'package:perpus_app/views/books/book_form_dialog.dart';

Map<String, dynamic> bookJson(int id, {String title = 'Buku'}) => {
      'id': id,
      'title': '$title $id',
      'author': 'Penulis',
      'publisher': 'Penerbit Test',
      'isbn': 'ISBN$id',
      'published_year': 2005,
      'stock': 3,
      'description': 'Deskripsi buku test',
      'created_at': '2026-11-09T14:20:25.000000Z',
      'updated_at': '2026-11-09T14:20:25.000000Z',
    };

/// Repository palsu: 2 halaman data, create bisa disetel gagal (ISBN duplikat).
class FakeBookRepository extends BookRepository {
  FakeBookRepository() : super(ApiService(Dio()));
  bool failCreate = false;

  @override
  Future<BookPage> getBooks({String? search, int page = 1}) async => BookPage(
        books: [for (var i = 1; i <= 2; i++) BookModel.fromJson(bookJson((page - 1) * 2 + i))],
        currentPage: page,
        lastPage: 2,
        total: 4,
      );

  @override
  Future<BookModel> createBook(Map<String, dynamic> payload) async {
    if (failCreate) {
      throw const ApiException('The isbn has already been taken.',
          statusCode: 422, fieldErrors: {'isbn': 'The isbn has already been taken.'});
    }
    return BookModel.fromJson({...bookJson(99), ...payload});
  }

  @override
  Future<void> deleteBook(int id) async {}
}

void main() {
  group('Model & parsing respons backend', () {
    test('BookPage.fromJson membaca data + meta paginasi Laravel', () {
      final page = BookPage.fromJson({
        'data': [bookJson(1), bookJson(2)],
        'links': {},
        'meta': {'current_page': 1, 'last_page': 3, 'per_page': 2, 'total': 6},
      });
      expect(page.books.length, 2);
      expect(page.books.first.publishedYear, 2005);
      expect(page.hasMore, isTrue);
      expect(page.total, 6);
    });

    test('UserModel.fromJson membaca user dan createdAt (Tugas B)', () {
      final user = UserModel.fromJson({
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': '2026-11-09T14:20:25.000000Z',
      });
      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.year, 2026);
    });

    test('ApiException membaca error validasi 422', () {
      final e = ApiException.fromDio(DioException(
        requestOptions: RequestOptions(path: '/books'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/books'),
          statusCode: 422,
          data: {
            'message': 'The isbn has already been taken.',
            'errors': {
              'isbn': ['The isbn has already been taken.'],
            },
          },
        ),
      ));
      expect(e.statusCode, 422);
      expect(e.fieldErrors['isbn'], 'The isbn has already been taken.');
    });

    test('ApiException memberi pesan jelas saat server mati', () {
      final e = ApiException.fromDio(DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.connectionError,
      ));
      expect(e.message, contains('Tidak dapat terhubung'));
    });
  });

  group('BookNotifier', () {
    late ProviderContainer container;
    late FakeBookRepository repo;

    setUp(() {
      repo = FakeBookRepository();
      container = ProviderContainer(
        overrides: [bookRepositoryProvider.overrideWithValue(repo)],
      );
    });
    tearDown(() => container.dispose());

    test('load + loadMore menggabungkan halaman', () async {
      final vm = container.read(bookProvider.notifier);
      await vm.load();
      expect(container.read(bookProvider).books.length, 2);
      expect(container.read(bookProvider).hasMore, isTrue);

      await vm.loadMore();
      final s = container.read(bookProvider);
      expect(s.books.map((b) => b.id), [1, 2, 3, 4]);
      expect(s.hasMore, isFalse);
    });

    test('create gagal tidak menghapus daftar & mengembalikan error field', () async {
      final vm = container.read(bookProvider.notifier);
      await vm.load();
      repo.failCreate = true;
      final err = await vm.create({'isbn': 'ISBN1'});
      expect(err?.fieldErrors['isbn'], isNotNull);
      final s = container.read(bookProvider);
      expect(s.books.length, 2);
      expect(s.error, isNull);
    });

    test('delete menghapus buku dari daftar', () async {
      final vm = container.read(bookProvider.notifier);
      await vm.load();
      expect(await vm.delete(1), isNull);
      expect(container.read(bookProvider).books.map((b) => b.id), [2]);
    });
  });

  testWidgets('Form buku: validasi lokal & error ISBN dari backend tampil', (tester) async {
    Map<String, dynamic>? sent;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BookFormDialog(onSubmit: (payload) async {
          sent = payload;
          return const ApiException('dup',
              statusCode: 422, fieldErrors: {'isbn': 'The isbn has already been taken.'});
        }),
      ),
    ));

    // Submit kosong → validasi lokal, tidak memanggil API
    await tester.tap(find.text('Tambah'));
    await tester.pump();
    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect(sent, isNull);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Laskar Pelangi');
    await tester.enterText(fields.at(1), 'Andrea Hirata');
    await tester.enterText(fields.at(3), '9789793062792');
    await tester.enterText(fields.at(4), '2005');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(sent?['published_year'], 2005);
    expect(sent?['publisher'], isNull); // kosong → null, bukan ''
    expect(find.text('The isbn has already been taken.'), findsOneWidget);
    expect(find.byType(BookFormDialog), findsOneWidget); // dialog tetap terbuka
  });

  testWidgets('BookDetailView: menampilkan informasi buku secara lengkap (Tugas A)', (tester) async {
    final book = BookModel.fromJson(bookJson(1, title: 'Flutter Advanced'));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BookDetailView(book: book),
        ),
      ),
    );

    expect(find.text('Detail Buku'), findsOneWidget);
    expect(find.text('Flutter Advanced 1'), findsOneWidget);
    expect(find.text('Penulis: Penulis'), findsOneWidget);
    expect(find.text('Penerbit Test'), findsOneWidget);
    expect(find.text('ISBN1'), findsOneWidget);
    expect(find.text('Deskripsi buku test'), findsOneWidget);
    expect(find.text('Edit Buku'), findsWidgets);
    expect(find.text('Hapus Buku'), findsWidgets);
  });
}
