# Flutter 設計方針（名刺アプリ）

## 参考資料

- [いちから始めるFlutterモバイルアプリ開発 - モデルクラスの作成](https://zenn.dev/heyhey1028/books/flutter-basics/viewer/hands_on_2)
- [Dartの抽象クラスとインターフェース](https://flutter.cmatrix.co.jp/school/beginner-of-flutter-6/)
- [Class Widget vs Functional Widget](https://future-architect.github.io/articles/20220316a/)
- [クラスとオブジェクト指向プログラミング](https://zenn.dev/haruki1009/books/768cb232536200/viewer/ed8d3c)
- [Flutterレイヤードアーキテクチャ](https://thinkit.co.jp/article/38326)

---

## 参考記事からの主な知見

| 出典 | ポイント |
|------|----------|
| future-architect | **Class Widget を原則必須**。Functional Widget は private 補助メソッドのみ許容 |
| thinkit | **レイヤードアーキテクチャ**（presentation / domain / data）で関心を分離 |
| cmatrix | 抽象クラス・インターフェース・Mixin でコード再利用性・テスト性を高める |
| zenn (heyhey) | モデルクラスを独立させてドメイン知識をUIから切り離す |

---

## ディレクトリ構成

### 方針

- `features/` — 機能単位で分割（Flutter コミュニティの標準）
- `core/` — テーマ・定数・utils など **インフラ寄り** の共通処理（将来用）
- `widgets/` と `core/` は置くファイルが生まれたタイミングで作成する（空ディレクトリは作らない）

### 全体像（将来の完成形）

```
lib/
├── main.dart                          # runApp のみ。エントリポイント専用
├── app.dart                           # BusinessCardApp（MaterialApp設定）
├── features/
│   └── business_card/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── home_page.dart     # MyHomePage（画面単位）
│       │   └── widgets/
│       │       ├── business_card_view.dart   # 名刺全体の表示 Widget
│       │       ├── card_name_section.dart    # 氏名・肩書き部分
│       │       └── card_contact_section.dart # 連絡先部分
│       └── domain/
│           └── models/
│               └── business_card.dart # BusinessCard モデル（氏名・会社等）
└── core/
    ├── theme/
    │   └── app_theme.dart             # MaterialTheme 定義
    └── utils/
        └── string_utils.dart          # 汎用文字列ユーティリティ等
```

### 現在の実装済み構成

```
lib/
├── main.dart          # runApp(const BusinessCardApp()) のみ
├── app.dart           # BusinessCardApp（MaterialApp設定）
└── features/
    └── business_card/
        ├── presentation/
        │   └── pages/
        │       └── home_page.dart     # MyHomePage
        └── domain/
            └── models/
                └── business_card.dart # BusinessCard モデル（name / company / title / email / phone）
```

## 各ファイルの責務

| ファイル | 責務 |
|----------|------|
| `main.dart` | `runApp()` だけ。絶対に UI ロジックを書かない |
| `app.dart` | `MaterialApp` / テーマ / ルート設定 |
| `pages/home_page.dart` | 画面単位の Widget（`MyHomePage`） |
| `widgets/` | 1つの部品に責任を持つ小さい Class Widget |
| `models/business_card.dart` | データ構造のみ。UI に依存しない |

---

## Class Widget ルール

原則として **Class Widget** を使用する。Functional Widget はファイルトップレベルへの定義を禁止し、private メソッドに限定する。

```dart
// ✅ 原則：Class Widget
class BusinessCardWidget extends StatelessWidget { ... }

// ✅ 許容：private メソッド（switch/三項演算子で分岐するだけの場合）
Widget _buildContent() => isLoading ? ... : ...;

// ❌ 禁止：Functional Widget をトップレベルに定義
Widget buildCard() { ... }
```

### Class Widget を優先する理由

1. **パフォーマンス** — リビルド範囲を限定できる
2. **バグ回避** — BuildContext の参照問題や Widget Key が自動的に適切に機能する
3. **テスト性** — ウィジェット単体でテストしやすい

---

## レイヤードアーキテクチャ

「関心の分離」を軸に、以下の4層で責務を分割する。

| 層 | 責務 |
|----|------|
| **Presentation** | UI 構築とユーザー対話 |
| **Domain** | ビジネスロジックとエンティティ定義 |
| **Data** | 外部データソースとの通信（将来用） |
| **State** | アプリケーション状態の保持（将来用） |

依存方向は **上位層 → 下位層** のみ。下位層は上位層を知らない。

---

## OOP 設計原則

- **単一責任原則** — 各クラスは特定の「関心事」に集中する
- **依存性の逆転** — 抽象インターフェースに依存し、実装を分離する（Repository パターン）
- **抽象クラス / Mixin** — 共通処理を抽象クラスで定義し、Mixin で機能を再利用する
