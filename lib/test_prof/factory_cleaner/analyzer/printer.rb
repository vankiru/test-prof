# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Printer
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def print
          #print_definitions
          #puts
          print_factories
        end

        def print_definitions
          puts "======================================="
          puts "============= Definitions ============="

          @analyzer.definitions.each do |definition|
            puts "---- #{definition} ----"
            puts definition.examples
          end
        end

        def print_factories
          puts "======================================="
          puts "============== Factories =============="

          puts @analyzer.factories.count
          @analyzer.factories.top_level.each do |name, variations|
            puts "-- #{name} --"
            variations.each do |definition, overrides|
              puts "  => #{definition}"
              overrides.each do |override|
                puts "    #{override} => #{override.count}"
              end
            end
          end
        end
      end
    end
  end
end
