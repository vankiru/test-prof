# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Printer
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def print
          @analyzer.factories.each do |name, variations|
            puts "=== #{name} ==="
            variations.each do |factory, stat|
              puts "#{factory.inspect} => #{stat}"
            end
          end
          #puts "factories = #{@analyzer.factories}"
          #puts "======================================="
          #puts "lets = #{@analyzer.lets}"
        end
      end
    end
  end
end
