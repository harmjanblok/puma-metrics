# frozen_string_literal: true

require 'json'
require 'prometheus/client/formats/text'
require 'puma/metrics/parser'

module Puma
  module Metrics
    MetricsNotAvailableError = Class.new(StandardError)

    class App
      def initialize(launcher)
        @launcher = launcher
        clustered = (@launcher.options[:workers] || 0) > 0
        @parser = Parser.new(clustered: clustered)
      end

      def call(_env)
        retrieve_and_parse_stats!
        [
          200,
          { 'Content-Type' => 'text/plain' },
          [Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)]
        ]
      rescue MetricsNotAvailableError => e
        [503, { 'Content-Type' => 'text/plain' }, ["#{e.message}\n"]]
      end

      def retrieve_and_parse_stats!
        puma_stats = fetch_stats
        if puma_stats.is_a?(Hash) # Modern Puma outputs stats as a Symbol-keyed Hash
          @parser.parse(puma_stats)
        else
          @parser.parse(JSON.parse(puma_stats, symbolize_names: true))
        end
      end

      private

      def fetch_stats
        @launcher.stats
      rescue NoMethodError
        # Puma plugins are started in the background along with the server, so
        # there's a chance that a request will arrive to the server started by
        # this plugin before the main one has been registered in the launcher.
        #
        # If that happens, fetching the stats fails because `@server` is nil,
        # causing a NoMethodError.
        #
        # Ideally this code should detect the case using the launcher public
        # interface, but no methods expose the information that is required for
        # that.
        raise MetricsNotAvailableError, 'Puma is booting up. Stats are not yet ready.'
      end
    end
  end
end
