# frozen_string_literal: true

module Puma
  module Metrics
    module Config
      class << self
        attr_accessor :registry
      end
    end
  end
end
