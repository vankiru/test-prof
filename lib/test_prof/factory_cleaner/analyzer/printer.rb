# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Printer
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def print
          puts "factories = #{@analyzer.factories}"
          puts "======================================="
          puts "lets = #{@analyzer.lets}"
        end
      end
    end
  end
end
