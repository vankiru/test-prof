# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Definitions
        include Enumerable

        def initialize(definitions)
          @definitions = definitions
        end

        def shift(by:, from:, to: nil)
          from = from.first if from.is_a?(Range)
          range = from..to

          @definitions.each do |definition, count|
            if definition.location.line_number.in?(range)
              definition.location.shift(by)
            end
          end
        end

        def each(&block)
          @definitions.each(&block)
        end
      end
    end
  end
end
