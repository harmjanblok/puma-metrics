require 'helpers'
require 'minitest/autorun'
require 'puma/configuration'

class TestClusterOne < Minitest::Test
  include Helpers

  def configuration
    Puma::Configuration.new do |config|
      config.bind 'tcp://127.0.0.1:0'
      config.metrics_url 'tcp://127.0.0.1:9394'
      config.plugin 'metrics'
      config.quiet
      config.workers 1
      config.app do |_env|
        [200, {}, ['hello world']]
      end
    end
  end

  def metrics
    l = ['{index="0"}']
    [
      { name: 'puma_backlog',        type: 'gauge', labels: l,  value: 0.0 },
      { name: 'puma_booted_workers', type: 'gauge', labels: [], value: 1.0 },
      { name: 'puma_max_threads',    type: 'gauge', labels: l,  value: 16.0 },
      { name: 'puma_old_workers',    type: 'gauge', labels: [], value: 0.0 },
      { name: 'puma_pool_capacity',  type: 'gauge', labels: l,  value: 16.0 },
      { name: 'puma_running',        type: 'gauge', labels: l,  value: 0.0 },
      { name: 'puma_workers',        type: 'gauge', labels: [], value: 1.0 }
    ]
  end
end
