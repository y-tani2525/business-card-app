# Flutter 設計方針（名刺アプリ）

## 参考資料

- [いちから始めるFlutterモバイルアプリ開発 - モデルクラスの作成](https://zenn.dev/heyhey1028/books/flutter-basics/viewer/hands_on_2)
- [Dartの抽象クラスとインターフェース](https://flutter.cmatrix.co.jp/school/beginner-of-flutter-6/)
- [Class Widget vs Functional Widget](https://future-architect.github.io/articles/20220316a/)
- [クラスとオブジェクト指向プログラミング](https://zenn.dev/haruki1009/books/768cb232536200/viewer/ed8d3c)
- [Flutterレイヤードアーキテクチャ](https://thinkit.co.jp/article/38326)

---

## アーキテクチャの選定

### 採用スタイル：Feature-First 軽量レイヤードアーキテクチャ

このアプリは **クリーンアーキテクチャの考え方を部分採用した、Feature-First の軽量レイヤードアーキテクチャ** を採用している。

| アーキテクチャ | 採用状況 | 理由 |
|---------------|----------|------|
| クリーンアーキテクチャ | 部分採用 | Presentation / Domain の分離という核心部分のみ取り入れる。Use Case 層は現時点では不要なため省略 |
| DDD（ドメイン駆動設計） | 概念のみ採用 | `domain/models/` にエンティティを置くという考え方を借用。集約・値オブジェクト・リポジトリは将来対応 |
| Feature-First | 採用 | 画面・機能ごとにディレクトリをまとめる Flutter コミュニティの標準構成 |

### クリーンアーキテクチャとの対応関係

クリーンアーキテクチャは「同心円状の層」で表現されるが、このアプリでは以下のように対応させる。

```
クリーンアーキテクチャ          このアプリ
─────────────────────────────────────────────
Frameworks & Drivers      →  Flutter / Web（フレームワーク自体）
Interface Adapters        →  presentation/pages/, presentation/widgets/
Use Cases                 →  （現時点では省略。ロジックが増えたら追加）
Entities                  →  domain/models/
```

> **なぜ Use Case 層を省略するか**
> 名刺の表示のみで外部 API や複雑なビジネスロジックがない現段階では、
> Use Case を挟むと薄いクラスが増えて可読性が下がるため省略する。
> データ取得・保存が発生した時点で追加する。

---

## 依存関係

### 依存の方向

依存は **外側 → 内側（Presentation → Domain）** の一方向のみ。  
内側（Domain）は外側を一切知らない。

```
main.dart
    │
    ▼
app.dart
    │
    ▼
presentation/pages/          presentation/widgets/
    │                               │
    └───────────┬───────────────────┘
                ▼
         domain/models/
         （誰にも依存しない）
```

### 各層が依存してよいもの・してはいけないもの

| 層 | 依存してよいもの | 依存してはいけないもの |
|----|----------------|----------------------|
| `main.dart` | `app.dart` のみ | presentation / domain / Flutter Widget |
| `app.dart` | `presentation/pages/`・Flutter | `domain/` を直接触らない |
| `presentation/` | `domain/models/`・Flutter Widget | 外部 API・DB・他 feature の presentation |
| `domain/models/` | Dart の標準ライブラリのみ | Flutter・外部パッケージ・他の層 |

### 具体的な import の例

```dart
// ✅ presentation が domain/models を参照するのは OK
import 'package:business_card_app/features/business_card/domain/models/business_card.dart';

// ❌ domain が presentation を参照するのは禁止
import 'package:business_card_app/features/business_card/presentation/pages/home_page.dart';

// ❌ presentation が別 feature の presentation を直接参照するのは禁止
import 'package:business_card_app/features/other_feature/presentation/...';
```

---

## レイヤー詳細

### Presentation 層（`presentation/`）

UI の構築とユーザー操作の受け口。Flutter Widget のみで構成する。

| ディレクトリ | 役割 |
|------------|------|
| `pages/` | 画面単位の Widget。Navigator でルーティングされる単位 |
| `widgets/` | pages 内で使う再利用可能な部品。1ファイル1クラスを原則とする |

- ビジネスロジックを書かない。データの加工・判定は domain に委ねる
- `domain/models/` のデータを受け取って表示するだけに徹する

### Domain 層（`domain/`）

アプリの中核。Flutter にも外部サービスにも依存しない純粋な Dart クラスで構成する。

| ディレクトリ | 役割 |
|------------|------|
| `models/` | エンティティ（名刺データ等）の定義 |
| `repositories/`（将来） | データ取得の抽象インターフェース定義 |
| `usecases/`（将来） | ビジネスロジックのユニット |

- Flutter を import しない
- `const` コンストラクタを使い immutable（不変）に設計する

### Data 層（将来追加）

外部 API・ローカル DB との通信を担う。Domain の Repository インターフェースを実装する。

```
domain/repositories/business_card_repository.dart  ← 抽象（interface）
data/repositories/business_card_repository_impl.dart ← 実装
```

Presentation は抽象にだけ依存するため、実装を差し替えてもUIは変わらない。

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
│       │   │   └── home_page.dart          # MyHomePage（画面単位）
│       │   └── widgets/
│       │       ├── business_card_view.dart  # 名刺全体の表示 Widget
│       │       ├── card_name_section.dart   # 氏名・肩書き部分
│       │       └── card_contact_section.dart # 連絡先部分
│       ├── domain/
│       │   ├── models/
│       │   │   └── business_card.dart       # BusinessCard エンティティ
│       │   └── repositories/               # （将来）抽象インターフェース
│       └── data/                           # （将来）Repository 実装
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

---

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

## OOP 設計原則

- **単一責任原則** — 各クラスは特定の「関心事」に集中する
- **依存性の逆転** — 抽象インターフェースに依存し、実装を分離する（Repository パターン）
- **抽象クラス / Mixin** — 共通処理を抽象クラスで定義し、Mixin で機能を再利用する
- **Immutability** — `domain/models/` のクラスは `const` コンストラクタ + `final` フィールドで不変にする
