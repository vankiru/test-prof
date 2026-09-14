# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        class Template
          def initialize(name:, parent:, block:, **options)
            @name = name
            @parent = parent
            @block = block
            @options = options
          end
        end
      end
    end
  end
end
