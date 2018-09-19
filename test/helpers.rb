require 'net/http'
require 'prometheus/client'
require 'puma'
require 'puma/configuration'
require 'puma/events'
require 'puma/metrics/parser'
require 'puma/plugin/metrics'
require 'timeout'

module Helpers
  def response
    @response ||= Net::HTTP.start uri.host, uri.port do |http|
      http.request Net::HTTP::Get.new('/metrics')
    end.body
  end

  def uri
    URI.parse @configuration.options[:metrics_url]
  end

  def start_server(configuration)
    @wait, @ready = IO.pipe

    @events = Puma::Events.strings
    @events.on_booted { @ready << '!' }

    @configuration = configuration
    @launcher = Puma::Launcher.new(@configuration, events: @events)

    @launcher_thread = Thread.new do
      Thread.current.abort_on_exception = true
      @launcher.run
    end
    wait_booted
  end

  def stop_server
    Prometheus::Client.instance_eval { @registry = nil }
    @launcher.stop
    @wait.close
    @ready.close
    @launcher_thread.join
  end

  def assert_response_includes_metrics(metrics)
    metrics.each do |metric|
      assert_includes response, "# TYPE #{metric[:name]} #{metric[:type]}\n"
      metric[:labels].each do |label|
        assert_includes response, "#{metric[:name]}#{label} #{metric[:value]}\n"
      end
    end
  end

  def cluster_booted?
    worker_status = JSON.parse(Puma.stats)['worker_status']

    (worker_status.length == @configuration.options[:workers]) &&
      (worker_status.all? { |w| w.key?('last_status') && w['last_status'].key?('backlog') })
  end

  def wait_booted
    @wait.sysread 1
    return unless @configuration.options[:workers] > 0

    # Wait for workers to report 'last_status'
    Timeout.timeout(15) do
      sleep 0.2 until cluster_booted?
    end
  end
end
