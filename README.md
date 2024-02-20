# puma-metrics

[![Release](https://github.com/harmjanblok/puma-metrics/actions/workflows/workflow.yml/badge.svg)](https://github.com/harmjanblok/puma-metrics/actions/workflows/workflow.yml)

A puma plugin to export Puma's internal statistics as Prometheus metrics.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma-metrics'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install puma-metrics


## Usage

Add following lines to your puma `config.rb` (see
[Configuration File](https://github.com/puma/puma#configuration-file)):

```ruby
# config/puma.rb
# Load the metrics plugin
plugin 'metrics'

# Bind the metric server to "url". "tcp://" is the only accepted protocol.
#
# The default is "tcp://0.0.0.0:9393".
# metrics_url 'tcp://0.0.0.0:9393'
```

## Credits

The gem is inspired by the following projects:
* https://github.com/puma/puma
* https://github.com/puma/puma-heroku

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

