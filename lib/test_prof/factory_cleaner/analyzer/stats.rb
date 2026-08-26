# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Stats
        include Enumerable

        def initialize
          @data = Set.new
        end

        def <<(item)
          item.count += 1
          @data << item
        end

        def each(&block)
          @data.each(&block)
        end

        def to_s
          @data.to_s
        end
      end
    end
  end
end
