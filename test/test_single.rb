# frozen_string_literal: true

require 'helpers'
require 'minitest/autorun'
require 'puma/configuration'

class TestSingle < Minitest::Test
  include Helpers

  def setup
    start_server(configuration)
  end

  def teardown
    stop_server
  end

  def configuration
    Puma::Configuration.new do |config|
      config.bind 'tcp://127.0.0.1:0'
      config.plugin 'metrics'
      config.quiet
      config.app do |_env|
        [200, {}, ['hello world']]
      end
      config.threads(0, 16) # default for non MRI
    end
  end

  def metrics
    l = ['{index="0"}']
    [
      { name: 'puma_backlog',       type: 'gauge', labels: l,  value: 0.0 },
      { name: 'puma_max_threads',   type: 'gauge', labels: l,  value: 16.0 },
      { name: 'puma_pool_capacity', type: 'gauge', labels: l,  value: 16.0 },
      { name: 'puma_running',       type: 'gauge', labels: l,  value: 0.0 },
      { name: 'puma_workers',       type: 'gauge', labels: [], value: 1.0 }
    ]
  end

  def test_metrics
    assert_response_includes_metrics(metrics)
  end
end
