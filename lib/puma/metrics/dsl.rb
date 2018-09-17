module Puma
  class DSL
    def metrics_url(url = 'tcp://0.0.0.0:9393')
      @options[:metrics_url] = url
    end
  end
end
