# frozen_string_literal: true

require 'prometheus/client'

module Puma
  module Metrics
    class Parser
      def initialize(clustered: false)
        register_default_metrics
        register_system_metrics
        register_clustered_metrics if clustered
      end

      def parse(symbol_keyed_stats, labels = {})
        symbol_keyed_stats.each do |key, value|
          value.each { |s| parse(s, labels.merge(index: s[:index])) } if key == :worker_status
          parse(value, labels) if key == :last_status
          update_metric(key, value, labels)
        end
      end

      private

      def register_system_metrics
        registry.gauge(:cpu_usage, docstring: 'cpu usage percent')
                .set(`ps x -o %cpu #{Process.pid} | tail -1`.strip.to_f)
        registry.gauge(:memory_usage, docstring: 'memory usage bytes')
                .set(`ps x -o rss #{Process.pid} | tail -1`.strip.to_i)
      end

      def register_clustered_metrics
        registry.gauge(:puma_booted_workers,
                       docstring: 'Number of booted workers')
                .set(1)
        registry.gauge(:puma_old_workers,
                       docstring: 'Number of old workers')
                .set(0)
      end

      def register_default_metrics # rubocop:disable Metrics/MethodLength
        registry.gauge(:puma_backlog,
                       docstring: 'Number of established but unaccepted connections in the backlog',
                       labels: [:index],
                       preset_labels: { index: 0 })
        registry.gauge(:puma_running,
                       docstring: 'Number of running worker threads',
                       labels: [:index],
                       preset_labels: { index: 0 })
        registry.gauge(:puma_pool_capacity,
                       docstring: 'Number of allocatable worker threads',
                       labels: [:index],
                       preset_labels: { index: 0 })
        registry.gauge(:puma_max_threads,
                       docstring: 'Maximum number of worker threads',
                       labels: [:index],
                       preset_labels: { index: 0 })
        registry.gauge(:puma_requests_count,
                       docstring: 'Number of processed requests',
                       labels: [:index],
                       preset_labels: { index: 0 })
        registry.gauge(:puma_workers,
                       docstring: 'Number of configured workers')
                .set(1)
      end

      def registry
        Prometheus::Client.registry
      end

      def update_metric(key, value, labels)
        return if registry.get("puma_#{key}").nil?

        registry.get("puma_#{key}").set(value, labels: labels)
      end
    end
  end
end
