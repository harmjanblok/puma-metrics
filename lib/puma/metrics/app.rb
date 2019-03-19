require 'json'
require 'prometheus/client/formats/text'
require 'puma/metrics/parser'

module Puma
  module Metrics
    class App
      def initialize(launcher)
        @launcher = launcher
        clustered = (@launcher.options[:workers] || 0) > 0
        @parser = Parser.new clustered
      end

      def call(_env)
        parse
        [
          200,
          { 'Content-Type' => 'text/plain' },
          [Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)]
        ]
      end

      def parse
        @parser.parse JSON.parse(@launcher.stats)
      end
    end
  end
end
