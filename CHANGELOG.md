# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-12

### Added
- Initial release of the `industry_time` gem.
- Ability to parse 24+ hour format times using `Time.parse` and `Time.strptime`.
- Support for `DateTime` class (`parse`, `strptime`, `to_industry_format`).
- Global and scoped (`Refinements`) monkey patches.
- Rails (ActiveSupport) integration for `Time.zone.parse` and `ActiveSupport::TimeWithZone`.
- Safe DST boundary calculations via the internal `shift_days` method.
- Japanese and English documentation (README).
