# frozen_string_literal: true

require 'json'
require 'prometheus/client/formats/text'
require 'puma/metrics/config'
require 'puma/metrics/parser'

module Puma
  module Metrics
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
          [Prometheus::Client::Formats::Text.marshal(Puma::Metrics::Config.registry)]
        ]
      end

      def retrieve_and_parse_stats!
        puma_stats = @launcher.stats
        if puma_stats.is_a?(Hash) # Modern Puma outputs stats as a Symbol-keyed Hash
          @parser.parse(puma_stats)
        else
          @parser.parse(JSON.parse(puma_stats, symbolize_names: true))
        end
      end
    end
  end
end
