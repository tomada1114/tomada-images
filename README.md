# tomada-images

GitHub Pages で画像を配信するためのリポジトリ。

## URL

```
https://tomada1114.github.io/tomada-images/
```

## ディレクトリ構造

```
tomada-images/
├── articles/      # 技術記事用（Zenn, Qiita等）
├── youtube/       # YouTube用
└── presentations/ # スライド用
```

## 使い方

1. 画像を適切なディレクトリに追加
2. `make smart-compress-all` で圧縮
3. `git push`
4. URL をコピーして使用

```
https://tomada1114.github.io/tomada-images/articles/{記事名}/{画像ファイル}
```

## 画像圧縮

```bash
# 未圧縮ファイルのみ処理（推奨）
make smart-compress-all

# 特定ディレクトリのみ
make smart-compress path=articles/your_directory

# 全ファイル強制再圧縮
make optimize-images path=articles/your_directory
```

- 1920px以上の画像は自動リサイズ
- `.checksums` で圧縮済みファイルを管理
