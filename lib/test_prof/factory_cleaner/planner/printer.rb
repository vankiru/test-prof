# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Printer
        def initialize(planner)
          @planner = planner
        end

        def print
          puts "=== Planner Factories Order ==="
          puts "  #{@planner.depth_order.join(" => ")}"

          puts
          puts "=== Planner Factories ==="
          @planner.factories.each do |name, variations|
            puts "-- #{name} --"
            variations.each do |definition, overrides|
              puts "=> #{definition}"
              overrides.each do |override, count|
                puts "    #{override} => #{count}"
              end
            end
          end

          puts
          puts "=== Plan ==="
          @planner.plan.ordered.each do |patch|
            puts "  #{patch}"
          end
        end
      end
    end
  end
end
