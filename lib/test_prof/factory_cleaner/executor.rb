# frozen_string_literal: true

require "test_prof/factory_cleaner/executor/editor"
require "test_prof/factory_cleaner/executor/definitions"
require "test_prof/factory_cleaner/executor/code"
require "test_prof/factory_cleaner/executor/logger"

module TestProf
  module FactoryCleaner
    class Executor
      def initialize(planner, analyzer)
        @planner = planner
        @analyzer = analyzer
      end

      def run
        puts "======================================="
        puts "============ Executor Log ============="


        @planner.plans.each do |file_path, plan|
          patch_file(file_path, plan) unless plan.shared_example?
        end

        puts
        puts "===> Finished"
      end

      private

      def patch_file(file_path, plan)
        puts
        puts "=== #{file_path} ==="
        puts

        code = Code.new(file_path, @analyzer.definitions[file_path])
        code.read

        plan.each do |patch|
          puts "-- #{patch} --"
          patch.apply(code)
          puts
        end

        code.write
      end
    end
  end
end
