require 'helpers'
require 'minitest/autorun'
require 'puma/configuration'

class TestSignals < Minitest::Test
  include Helpers

  def setup
    start_server(configuration)
    assert_includes response, '# TYPE puma_backlog gauge'
  end

  def teardown
    stop_server
  end

  def configuration
    Puma::Configuration.new do |config|
      config.bind 'tcp://127.0.0.1:0'
      config.metrics_url 'tcp://127.0.0.1:9392'
      config.plugin 'metrics'
      config.quiet
      config.app { [200, {}, ['hello world']] }
    end
  end

  def test_stop
    @launcher.stop
    sleep 1
    assert_raises(Errno::ECONNREFUSED) do
      Net::HTTP.start uri.host, uri.port do |http|
        http.request Net::HTTP::Get.new('/metrics')
      end
    end
  end
end
