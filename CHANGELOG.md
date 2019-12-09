# Changelog

## Pending

Changes:
- Relax prometheus-client to '>= 0.10'

## 1.1.0

Changes:
- Upgrade prometheus-client to '~> 0.10'

Housekeeping:
- Set target version to 2.6
- Added editorconfig

## 1.0.3

Features:
- can be used with puma 3 or puma 4

## 1.0.2

Bugfixes:
- terminate metrics server without IO errors [#7](https://github.com/harmjanblok/puma-metrics/pull/7)

## 1.0.1

Bugfixes:
- `metrics_url` in `config/puma.rb` should be optional

## 1.0.0

Initial release of the `puma-metrics` gem.
