// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'models/book_model.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/splash_view.dart';
import 'views/books/book_detail_view.dart';
import 'views/books/books_view.dart';
import 'views/profile/profile_view.dart';

void main() {
  runApp(const ProviderScope(child: PerpusApp()));
}

class PerpusApp extends StatelessWidget {
  const PerpusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashView(),
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.register: (_) => const RegisterView(),
        AppRoutes.books: (_) => const BooksView(),
        AppRoutes.bookDetail: (ctx) {
          final book = ModalRoute.of(ctx)!.settings.arguments as BookModel;
          return BookDetailView(book: book);
        },
        AppRoutes.profile: (_) => const ProfileView(),
      },
    );
  }
}
