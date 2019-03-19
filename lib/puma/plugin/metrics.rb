require 'puma/metrics/dsl'

Puma::Plugin.create do
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def start(launcher)
    metrics_url = launcher.options[:metrics_url] || 'tcp://0.0.0.0:9393'
    metrics_poll = launcher.options[:metrics_poll] || 0

    metrics_url_disabled = %w[off none false].include?(metrics_url.downcase)

    # If the metrics URL, and polling, are both disabled, then return.
    return if metrics_url_disabled && metrics_poll.zero?

    require 'puma/metrics/app'

    @app = Puma::Metrics::App.new launcher

    if metrics_url_disabled
      poll(metrics_poll)
    else
      listen(launcher, metrics_url)
    end
  end

  def listen(launcher, metrics_url)
    metrics = Puma::Server.new @app, launcher.events
    metrics.min_threads = 0
    metrics.max_threads = 1

    uri = URI.parse metrics_url
    case uri.scheme
    when 'tcp'
      launcher.events.log "* Starting metrics server on #{metrics_url}"
      metrics.add_tcp_listener uri.host, uri.port
    else
      launcher.events.error "Invalid control URI: #{metrics_url}"
    end

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        metrics.stop
        metrics.binder.close
      end
    end

    metrics.run
  end

  def poll(metrics_poll)
    in_background do
      loop do
        sleep metrics_poll
        @app.parse
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
