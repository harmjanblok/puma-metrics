# frozen_string_literal: true

require 'puma/metrics/dsl'

Puma::Plugin.create do
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def start(launcher)
    str = launcher.options[:metrics_url] || 'tcp://0.0.0.0:9393'

    require 'puma/metrics/app'

    app = Puma::Metrics::App.new launcher
    uri = URI.parse str

    metrics = Puma::Server.new app, launcher.events, min_threads: 0, max_threads: 1

    case uri.scheme
    when 'tcp'
      launcher.log_writer.log "* Starting metrics server on #{str}"
      metrics.add_tcp_listener uri.host, uri.port
    else
      launcher.events.error "Invalid control URI: #{str}"
    end

    events = launcher.events
    action = -> { metrics.stop(true) unless metrics.shutting_down? }
    events.respond_to?(:after_stopped) ? events.after_stopped(&action) : events.on_stopped(&action)

    metrics.run
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
