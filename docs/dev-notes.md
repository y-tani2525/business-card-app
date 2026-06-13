# 開発メモ

## リファクタリング記録

### main.dart のクラス分割（2026-06-13）

`main.dart` に `BusinessCardApp` と `MyHomePage` が同居していた状態から、設計方針（[architecture.md](./architecture.md)）に沿ってファイルを分割した。

#### 変更前（main.dart）

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const BusinessCardApp());
}

class BusinessCardApp extends StatelessWidget {
  const BusinessCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '名刺',
      home: MyHomePage(title: '名刺'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('Business Card App'),
      ),
    );
  }
}
```

#### 変更後

| ファイル | 移動したクラス | 理由 |
|----------|---------------|------|
| `lib/main.dart` | `main()` のみ残す | エントリポイントは `runApp` だけにする |
| `lib/app.dart` | `BusinessCardApp` | MaterialApp 設定はアプリルートとして独立させる |
| `lib/features/business_card/presentation/pages/home_page.dart` | `MyHomePage` | 画面 Widget はプレゼンテーション層の pages/ に置く |

#### 変更後の main.dart

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const BusinessCardApp());
}
```
