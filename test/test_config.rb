require 'helpers'
require 'minitest/autorun'
require 'puma/configuration'

class TestConfig < Minitest::Test
  include Helpers

  def test_default_metrics_url
    configuration = Puma::Configuration.new do |config|
      config.bind 'tcp://127.0.0.1:0'
      config.plugin 'metrics'
      config.quiet
      config.app { [200, {}, ['hello world']] }
    end

    start_server(configuration)
    assert_includes response, '# TYPE puma_backlog gauge'
    stop_server
  end

  def test_plugin_disabled
    configuration = Puma::Configuration.new do |config|
      config.bind 'tcp://127.0.0.1:0'
      config.quiet
      config.app { [200, {}, ['hello world']] }
    end

    start_server(configuration)
    assert_raises(Errno::ECONNREFUSED) { response }
    stop_server
  end
end
