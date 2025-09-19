# frozen_string_literal: true

require 'helpers'
require 'minitest/autorun'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'puma/configuration'
require 'puma/metrics/middleware'
require 'rack'

class TestMiddleware < Minitest::Test
  include Helpers

  def setup
    start_server(configuration)
  end

  def teardown
    stop_server
  end

  def rack_app
    Rack::Builder.new do
      use Rack::Deflater
      use Prometheus::Middleware::Collector
      use Prometheus::Middleware::Exporter
      use Puma::Metrics::Middleware, logger: Logger.new(nil)
      run ->(_env) { [200, {}, ['hello world']] }
    end.to_app
  end

  def configuration
    Puma::Configuration.new do |config|
      config.app rack_app
      config.bind 'tcp://127.0.0.1:3000'
      config.metrics_url 'tcp://127.0.0.1:3000'
      config.quiet
      config.threads(0, 16)
      config.activate_control_app 'tcp://127.0.0.1:9293', { no_token: true }
    end
  end

  def l
    @l ||= ['{index="0"}']
  end

  def metrics
    [{ name: 'puma_backlog',        type: 'gauge', labels: l,  value: 0.0 },
     { name: 'puma_max_threads',    type: 'gauge', labels: l,  value: 16.0 },
     { name: 'puma_pool_capacity',  type: 'gauge', labels: l,  value: 15.0 },
     { name: 'puma_requests_count', type: 'gauge', labels: l,  value: 1.0 },
     { name: 'puma_running',        type: 'gauge', labels: l,  value: 1.0 }]
  end

  def test_metrics
    Net::HTTP.get_response(URI('http://127.0.0.1:3000'))
    assert_response_includes_metrics(metrics)
  end
end
