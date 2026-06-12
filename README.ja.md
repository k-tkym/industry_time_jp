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

## ライセンス

このGemは、[MITライセンス](https://opensource.org/licenses/MIT)の条件のもとでオープンソースとして利用可能です。
