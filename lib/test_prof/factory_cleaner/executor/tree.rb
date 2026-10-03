# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Tree
        attr_reader :spec

        def initialize(spec)
          @spec = spec
        end
      end
    end
  end
end
