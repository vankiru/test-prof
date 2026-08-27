# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Definitions
        def initialize(definitions)
          @definitions = definitions
        end

        def shift(by:, from:, to: nil)
          from = from.first if from.is_a?(Range)
          range = from..to

          puts "* shift #{range} by #{by}"
          @definitions.each do |definition, count|
            if definition.location.line_number.in?(range)
              definition.location.shift(by)
            end
          end
        end
      end
    end
  end
end
