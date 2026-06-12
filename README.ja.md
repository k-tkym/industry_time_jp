# IndustryTime

[English](README.md) | 日本語

`industry_time` は、日本の「業界時間」（25:00 や 28:00 のような24時間を超える時刻表現）をシームレスにパースおよびフォーマットするための標準 `Time` クラスの拡張を提供する Ruby ライブラリ（Gem）です。

**Refinement**（スコープを限定できるため推奨）またはグローバルな **Monkey Patch**（モンキーパッチ）のいずれかとして使用できます。

## インストール

アプリケーションの Gemfile に以下の行を追加してください：

```ruby
gem 'industry_time'
```

そして実行します：

```bash
$ bundle install
```

または、以下のように直接インストールすることもできます：

```bash
$ gem install industry_time
```

## 使い方

### 1. Refinements（推奨）

変更の影響範囲を特定のファイルやモジュールに限定したい場合は、Ruby の `Refinements` 機能を使用します：

```ruby
require 'industry_time'

class MyScheduler
  using IndustryTime

  def run
    # 25:30:00 を翌日の 01:30:00 として自動的にパースします
    time = Time.parse("2026-06-12 25:30:00")
    puts time # => 2026-06-13 01:30:00 +0900

    # Time オブジェクトを業界時間フォーマットに戻します
    puts time.to_industry_format # => "2026-06-12 25:30:00"
  end
end
```

### 2. モンキーパッチ（グローバル）

アプリケーション全体で拡張機能を利用したい場合：

```ruby
require 'industry_time'

# グローバルなモンキーパッチを有効化
IndustryTime.patch!

# どこからでも使用可能になります
time = Time.parse("2026-06-12 28:00:00")
puts time # => 2026-06-13 04:00:00 +0900

puts time.to_industry_format # => "2026-06-12 28:00:00"
```

### 設定

デフォルトでは、業界時間フォーマット変換の境界となる閾値は **午前4:00**（前日の `28:00` と同義）です。これをグローバルに設定するか、メソッド呼び出しごとに上書きすることができます：

```ruby
# グローバル設定
IndustryTime.threshold_hour = 5 # 閾値を午前5:00に設定

# メソッド呼び出しごとの上書き設定
time.to_industry_format(threshold_hour: 2)
```

## Rails (ActiveSupport) との連携

このGemは Ruby on Rails にも自動で対応します！ `ActiveSupport` が読み込まれている場合、`industry_time` は自動的に `ActiveSupport::TimeZone` と `ActiveSupport::TimeWithZone` に対してもパッチを適用します。

```ruby
# Time.zone を使ったパースが可能です
time = Time.zone.parse("2026-06-12 25:30:00")
puts time # => Sat, 13 Jun 2026 01:30:00 JST +09:00

# TimeWithZone オブジェクトのフォーマットも可能です
puts time.to_industry_format # => "2026-06-12 25:30:00"
```

Rails環境で使用する場合、Railsアプリの起動時（Railtie経由）にグローバルパッチが全自動で適用されるため、手動で `IndustryTime.patch!` を呼び出す必要はありません。

## 開発手順 (Development)

ローカル環境を汚さずに開発やテストを行うため、Docker環境が用意されています。

コンテナのビルドとインタラクティブシェルの起動：

```bash
docker compose build
docker compose run --rm app bash
```

コンテナ内に入った後は、以下のコマンドでテストや静的解析を実行できます：

```bash
# RSpecテストの実行
bundle exec rspec

# RuboCop（Linter & Formatter）の実行
bundle exec rubocop -A
```

## ライセンス

このGemは、[MITライセンス](https://opensource.org/licenses/MIT)の条件のもとでオープンソースとして利用可能です。
