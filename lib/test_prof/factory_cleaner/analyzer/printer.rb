# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Printer
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def print
          puts "======================================"
          puts "============== Analyzer =============="

          @analyzer.specs.each do |spec|
            print_spec(spec)
          end
        end

        def print_spec(spec)
          puts "====== #{file_path} ======"

          spec.factories.each do |factories|
            factories.each do |name, variations|
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
end
