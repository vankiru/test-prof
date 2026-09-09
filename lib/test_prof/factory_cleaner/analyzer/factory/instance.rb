# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        class Instance
          attr_reader :type, :example

          def initialize(type, example)
            @type = type
            @example = example
          end

          def group
            example.group
          end
        end
      end
    end
  end
end
