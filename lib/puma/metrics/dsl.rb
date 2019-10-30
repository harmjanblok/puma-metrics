# frozen_string_literal: true

module Puma
  class DSL
    def metrics_url(url)
      @options[:metrics_url] = url
    end
  end
end
