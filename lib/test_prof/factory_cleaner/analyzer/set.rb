# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Set
        include Enumerable

        def initialize
          @data = {}
        end

        def <<(item)
          @data[item] ||= 0
          @data[item] += 1
        end

        def each(&block)
          @data.each(&block)
        end

        def to_s
          @data
        end
      end
    end
  end
end
