# frozen_string_literal: true

require "test_prof/factory_cleaner/executor/editor"
require "test_prof/factory_cleaner/executor/definitions"
require "test_prof/factory_cleaner/executor/code"
require "test_prof/factory_cleaner/executor/printer"

module TestProf
  module FactoryCleaner
    class Executor
      def initialize(plan, analyzer)
        @plan = plan
        @file = analyzer
        @code = Code.new(file, analyzer.definitions)

        @printer = Priner.new(self)
      end

      def run
        @code.read

        @plan.each do |patch|
          patch.apply(code)
        end

        @code.write
        puts "Patching finished"
      end

      def print
        @printer.print
      end
    end
  end
end
