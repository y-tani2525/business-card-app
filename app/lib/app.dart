import 'package:flutter/material.dart';
import 'features/business_card/presentation/pages/home_page.dart';

class BusinessCardApp extends StatefulWidget {
  const BusinessCardApp({super.key});

  @override
  State<BusinessCardApp> createState() => _BusinessCardAppState();
}

class _BusinessCardAppState extends State<BusinessCardApp> {
  ThemeMode _themeMode = ThemeMode.system; // 初期値はシステム設定

  // system → light → dark の順にテーマを切り替える
  void _changeTheme() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '名刺',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode, // 状態変数を適用
      home: MyHomePage(
        title: '名刺',
        themeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}
