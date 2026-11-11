// lib/widgets/book_card.dart
import 'package:flutter/material.dart';
import '../core/routes/app_router.dart';
import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel(int stock) =>
      stock == 0 ? 'Stok: 0 (Habis)' : 'Stok: $stock';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(book.id.toString())),
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${book.author} · ${book.publishedYear} · '),
              TextSpan(
                text: _stockLabel(book.stock),
                style: TextStyle(
                  color: _stockColor(book.stock),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit, tooltip: 'Edit'),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Hapus',
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: book,
        ),
      ),
    );
  }
}

