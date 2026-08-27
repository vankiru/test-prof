# frozen_string_literal: true

require "test_prof/factory_cleaner/executor/editor"
require "test_prof/factory_cleaner/executor/definitions"
require "test_prof/factory_cleaner/executor/code"
require "test_prof/factory_cleaner/executor/printer"

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

        puts file_path
        code = Code.new(file_path, @analyzer.definitions)
        code.read

        @planner.plan.each do |patch|
          patch.apply(code)
        end

        #@code.write
        puts "Patching finished"
      end

      def file_path
        @file_path ||= @analyzer.factories.first.location.file_path
      end
    end
  end
end
