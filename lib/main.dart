import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/word_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WordbookApp());
}

class WordbookApp extends StatelessWidget {
  const WordbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordProvider()..load(),
      child: MaterialApp(
        title: '단어장',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const _AppRoot(),
      ),
    );
  }
}

/// Waits for [WordProvider] to finish loading data from disk before
/// showing the main UI.
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    if (!provider.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const HomeScreen();
  }
}
