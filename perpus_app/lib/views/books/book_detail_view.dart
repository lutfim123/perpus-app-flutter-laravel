// lib/views/books/book_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book_model.dart';
import '../../viewmodels/book_vm.dart';
import 'book_form_dialog.dart';

class BookDetailView extends ConsumerStatefulWidget {
  final BookModel book;

  const BookDetailView({super.key, required this.book});

  @override
  ConsumerState<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends ConsumerState<BookDetailView> {
  late BookModel _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel(int stock) =>
      stock == 0 ? 'Stok: 0 (Habis)' : 'Stok: $stock';

  Future<void> _openEditForm() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BookFormDialog(
        book: _currentBook,
        onSubmit: (payload) async {
          final err = await ref
              .read(bookProvider.notifier)
              .update(_currentBook.id, payload);
          if (err == null) {
            setState(() {
              _currentBook = BookModel(
                id: _currentBook.id,
                title: payload['title'] as String,
                author: payload['author'] as String,
                publisher: payload['publisher'] as String?,
                isbn: payload['isbn'] as String,
                publishedYear: payload['published_year'] as int,
                stock: payload['stock'] as int,
                description: payload['description'] as String?,
              );
            });
          }
          return err;
        },
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Hapus "${_currentBook.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final err = await ref.read(bookProvider.notifier).delete(_currentBook.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Buku dihapus'),
        backgroundColor: err != null ? Theme.of(context).colorScheme.error : null,
      ),
    );
    if (err == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Buku',
            onPressed: _openEditForm,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Hapus Buku',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(Icons.menu_book, size: 32, color: scheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentBook.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Penulis: ${_currentBook.author}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _infoRow(Icons.business, 'Penerbit', _currentBook.publisher ?? '-'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.qr_code, 'ISBN', _currentBook.isbn),
                      const SizedBox(height: 12),
                      _infoRow(Icons.calendar_today, 'Tahun Terbit', _currentBook.publishedYear.toString()),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Text('Status Stok: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            _stockLabel(_currentBook.stock),
                            style: TextStyle(
                              color: _stockColor(_currentBook.stock),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentBook.description ?? 'Tidak ada deskripsi untuk buku ini.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: _currentBook.description == null ? Colors.grey : null,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Buku'),
                      onPressed: _openEditForm,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus Buku'),
                      onPressed: _confirmDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

