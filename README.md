# IndustryTime

English | [日本語](README.ja.md)

`industry_time` is a Ruby library/gem that extends the standard `Time` class to seamlessly parse and format Japanese "industry time" (24+ hour format, such as 25:00, 28:00).

It can be used either as a scoped **Refinement** (recommended for safety) or a global **Monkey Patch**.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'industry_time'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install industry_time
```

## Usage

### 1. Refinements (Recommended)

To limit the scope of changes to specific files or modules, use Ruby's `Refinements` feature:

```ruby
require 'industry_time'

class MyScheduler
  using IndustryTime

  def run
    # Automatically parses 25:30:00 as 01:30:00 the next day
    time = Time.parse("2026-06-12 25:30:00")
    puts time # => 2026-06-13 01:30:00 +0900

    # Converts Time back to industry format
    puts time.to_industry_format # => "2026-06-12 25:30:00"
  end
end
```

### 2. Monkey Patching (Global)

If you want the extensions to be available globally throughout your entire application:

```ruby
require 'industry_time'

# Enable global monkey patches
IndustryTime.patch!

# Works anywhere now
time = Time.parse("2026-06-12 28:00:00")
puts time # => 2026-06-13 04:00:00 +0900

puts time.to_industry_format # => "2026-06-12 28:00:00"
```

### Configuration

By default, the boundary threshold for industry format conversion is **4:00 AM** (which maps to `28:00` of the previous day). You can configure this globally or override it per method call:

```ruby
# Global configuration
IndustryTime.threshold_hour = 5 # Set threshold to 5:00 AM

# Per-call override
time.to_industry_format(threshold_hour: 2)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
