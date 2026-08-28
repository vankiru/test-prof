# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Printer
        def initialize(planner)
          @planner = planner
        end

        def print
          puts "=== Plans ==="

          @planner.plans.each do |file_path, plan|
            puts
            puts "=== #{file_path} ==="
            puts "  #{plan.depth_order.join(" => ")}"

            puts
            plan.ordered.each do |patch|
              puts "  #{patch}"
            end
          end
        end
      end
    end
  end
end
