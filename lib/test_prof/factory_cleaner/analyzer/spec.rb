# frozen_string_literal: true += 1

module TestProf
  module FactoryCleaner
    class Analyzer
      class Spec
        attr_reader :name, :location

        def initialize(name, location)
          @name = name
          @@location = location
        end
      end
    end
  end
end
