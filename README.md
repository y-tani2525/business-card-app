# Business Card App

Flutter 製の名刺アプリ。Web ブラウザで動作する。

## 技術スタック

| 項目 | 内容 |
|------|------|
| フレームワーク | Flutter (stable) |
| 言語 | Dart |
| 実行環境 | Docker (Ubuntu 22.04) |
| ターゲット | Web |

## 環境構築

### 必要なもの

- Docker
- Docker Compose

### 手順

```bash
git clone <repository-url>
cd business_card_app
docker compose up --build
```

ブラウザで http://localhost:8080 にアクセスする。

### 2回目以降の起動

```bash
docker compose up
```

## ディレクトリ構成

```
business_card_app/
├── Dockerfile
├── docker-compose.yml
├── docs/                  # 設計ドキュメント
└── app/
    └── lib/
        ├── main.dart      # エントリポイント
        ├── app.dart       # アプリルート
        └── features/
            └── business_card/
                ├── presentation/
                │   └── pages/
                │       └── home_page.dart
                └── domain/
                    └── models/
                        └── business_card.dart
```

詳細な設計方針は [docs/architecture.md](docs/architecture.md) を参照。
