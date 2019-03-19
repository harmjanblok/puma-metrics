module Puma
  class DSL
    def metrics_poll(poll)
      @options[:metrics_poll] = poll.to_i
    end

    def metrics_url(url)
      @options[:metrics_url] = url
    end
  end
end
