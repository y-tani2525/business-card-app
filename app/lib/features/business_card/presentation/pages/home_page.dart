import 'package:flutter/material.dart';
import '../../domain/models/business_card.dart';
import '../widgets/business_card_view.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final String title;
  final ThemeMode themeMode;
  final VoidCallback onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final icon = switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };

    const card = BusinessCard(
      name: '山田 太郎',
      company: '株式会社サンプル',
      title: 'エンジニア',
      email: 'taro.yamada@example.com',
      phone: '090-1234-5678',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(icon),
            onPressed: onThemeChanged,
          )
        ]
      ),
      body: const Center(
        child: BusinessCardView(card: card),
      ),
    );
  }
}
