# frozen_string_literal: true

require 'net/http'
require 'json'
require 'puma/metrics/parser'

module Puma
  module Metrics
    # Middleware for collecting Puma metrics
    class Middleware
      DEFAULT_PUMA_CONTROL_APP_HOST = '127.0.0.1'.freeze
      DEFAULT_PUMA_CONTROL_APP_PORT = 9293

      def initialize(app, options = {})
        @app = app
        @control_app_host = options[:control_app_host] || DEFAULT_PUMA_CONTROL_APP_HOST
        @control_app_port = options[:control_app_port] || DEFAULT_PUMA_CONTROL_APP_PORT
        @logger = options[:logger] || Rails.logger
        @parser = options[:parser] || Puma::Metrics::Parser.new(clustered: options[:clustered] || true)
      end

      def call(env)
        @parser.parse(puma_stats)
        @app.call(env)
      end

      private

      def puma_stats
        response = fetch_stats
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body, symbolize_names: true)
        else
          @logger.error("Error fetching Puma stats: #{response.message}")
          {}
        end
      rescue StandardError => exception
        @logger.error("Error fetching Puma stats: #{exception.message}")
        {}
      end

      def fetch_stats
        Net::HTTP.get_response(@control_app_host, '/stats', @control_app_port)
      end
    end
  end
end
