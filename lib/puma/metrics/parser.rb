require 'prometheus/client'

module Puma
  module Metrics
    class Parser
      PUMA_METRICS = %i[
        backlog
        booted_workers
        max_threads
        old_workers
        pool_capacity
        running
        workers
      ].freeze

      def initialize(clustered = false)
        register_default_metrics
        register_clustered_metrics if clustered
      end

      def parse(metrics)
        metrics = metrics.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; } # symbolize
        labels = metrics.key?(:index) ? { index: metrics[:index] } : {} # include :index if present
        metrics.collect do |key, value|
          send(key, labels, value) # metric_name, labels, value
        end
      end

      private

      def last_status(labels, hash)
        parse(hash.merge(labels))
      end

      def method_missing(method, *args)
        return nil unless PUMA_METRICS.include?(method)

        registry
          .get("puma_#{method}") # Prometheus::Client::Registry#get(name)
          .set(*args) # Prometheus::Client::Gauge#set(labels={}, value)
      end

      def register_clustered_metrics
        registry.gauge(:puma_booted_workers, 'Number of booted workers').set({}, 1)
        registry.gauge(:puma_old_workers, 'Number of old workers').set({}, 0)
      end

      def register_default_metrics
        registry.gauge(:puma_backlog, 'Number of established but unaccepted connections in the backlog', index: 0)
        registry.gauge(:puma_running, 'Number of running worker threads', index: 0)
        registry.gauge(:puma_pool_capacity, 'Number of allocatable worker threads', index: 0)
        registry.gauge(:puma_max_threads, 'Maximum number of worker threads', index: 0)
        registry.gauge(:puma_workers, 'Number of configured workers').set({}, 1)
      end

      def registry
        Prometheus::Client.registry
      end

      def worker_status(_labels, workers)
        workers.each do |worker|
          parse(worker)
        end
      end
    end
  end
end
