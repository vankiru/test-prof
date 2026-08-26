# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Printer
        def initialize(planner)
          @planner = planner
        end

        def print
          puts "=== Factories Order ==="
          puts "  #{@planner.depth_order.join(" => ")}"

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
