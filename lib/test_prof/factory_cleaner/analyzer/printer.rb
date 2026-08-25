# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Printer
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def print
          puts "======================================="
          puts "============== Factories =============="

          @analyzer.factories.each do |name, variations|
            puts "----- #{name} -----"
            variations.each do |factory, stat|
              puts "#{factory} => #{stat}"
            end
          end

          #puts "======================================="
          #puts "=========== Factory Usages ============"

          #@analyzer.factory_usages.each do |name, parents|
            #puts "=== #{name} ==="
            #parents.each do |factory, stat|
              #puts "(#{factory[:name]}, #{factory[:definition]&.location}) => #{stat}"
            #end
          #end
        end
      end
    end
  end
end
