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

---

## Widget の組み合わせ方（StatelessWidget / Scaffold / Column / Row / Text）

### Flutter の基本概念：Widget ツリー

Flutter の UI はすべて **Widget の入れ子（ツリー）** で構成される。
親 Widget が子 Widget を `child` や `children` に渡すことで画面が作られる。

```
親Widget
 └── 子Widget
      └── 孫Widget
```

---

### 現在のコードのツリー構造

`app.dart` と `home_page.dart` で構成される現在の Widget ツリーは以下のとおり。

```
MaterialApp                          ← アプリ全体の設定（テーマ・ルート）
 └── MyHomePage (StatelessWidget)    ← 画面を表す Widget
      └── Scaffold                   ← 画面の骨格（AppBar + body の枠組み）
           ├── AppBar
           │    └── Text('名刺')     ← タイトル文字列
           └── Center                ← body を中央寄せ
                └── Text('ここに名刺の内容を表示する')
```

#### `StatelessWidget` の役割

状態を持たない Widget の基底クラス。`build()` メソッドで返す Widget ツリーが画面に描画される。
このアプリでは `BusinessCardApp` と `MyHomePage` の2つが `StatelessWidget` を継承している。

```dart
// BusinessCardApp：MaterialApp を返すだけ。テーマ・ルート設定の責務
class BusinessCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: '名刺'),
    );
  }
}

// MyHomePage：Scaffold を返す。画面レイアウトの責務
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

#### `Scaffold` の役割

**画面の骨格を提供する Widget**。`appBar`・`body`・`floatingActionButton` などのスロットを持ち、
Material Design の標準レイアウトを自動で組み立てる。

```dart
Scaffold(
  appBar: AppBar(title: Text('名刺')),  // 上部バー
  body: Center(...),                    // メインコンテンツ領域
)
```

#### `Text` の役割

文字列を描画する最小単位の Widget。`style` で装飾できる。

```dart
Text('名刺')                            // デフォルトスタイル
Text('名前', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
```

---

### Column・Row が加わると

名刺の情報（氏名・会社・連絡先）を縦・横に並べるとき `Column` と `Row` を使う。

| Widget | 並べる方向 | 使いどころ |
|--------|-----------|-----------|
| `Column` | 縦（上→下） | 氏名・会社・役職を縦に積む |
| `Row` | 横（左→右） | アイコンとテキストを横に並べる |

名刺表示に Column・Row を組み込んだ場合の Widget ツリー（将来イメージ）：

```
Scaffold
 └── Center
      └── Column                        ← 縦に積む
           ├── Text('山田 太郎')         ← 氏名
           ├── Text('株式会社〇〇')      ← 会社名
           ├── Text('エンジニア')        ← 役職
           └── Row                      ← 横に並べる
                ├── Icon(Icons.email)
                └── Text('taro@example.com')
```

対応するコード：

```dart
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('山田 太郎', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text('株式会社〇〇'),
      Text('エンジニア'),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email),
          SizedBox(width: 8),
          Text('taro@example.com'),
        ],
      ),
    ],
  ),
),
```

#### `Column` / `Row` の主要プロパティ

| プロパティ | 意味 |
|-----------|------|
| `mainAxisAlignment` | 主軸方向（Column なら縦、Row なら横）の揃え方 |
| `crossAxisAlignment` | 交差軸方向の揃え方 |
| `children` | 並べる Widget のリスト |

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,   // 縦方向：中央
  crossAxisAlignment: CrossAxisAlignment.start,  // 横方向：左揃え
  children: [...],
)
```

---

### まとめ：Widget の組み合わせパターン

```
StatelessWidget（クラス）
 └── Scaffold（画面骨格）
      └── Column（縦並び）
           ├── Text（文字）
           ├── Row（横並び）
           │    ├── Icon
           │    └── Text
           └── Text
```

- **StatelessWidget** — Widget ツリーを返すクラスの入れ物
- **Scaffold** — 画面の骨格。これを返すことで AppBar や body が使える
- **Column / Row** — 子 Widget を縦・横に並べるレイアウト Widget
- **Text** — 文字を表示する末端 Widget（`children` を持たない）
