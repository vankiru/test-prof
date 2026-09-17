# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Spec < Group
        def initialize(*args)
          super(*args)

          @factory_types = List.new
        end
      end
    end
  end
end
