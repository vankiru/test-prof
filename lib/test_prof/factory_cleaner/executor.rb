# frozen_string_literal: true

require "test_prof/factory_cleaner/executor/printer"

module TestProf
  module FactoryCleaner
    class Executor
      def initialize(analyzer, plan)
        @analyzer = analyzer
        @plan = plan

        @printer = Priner.new(self)
      end

      def run
      end

      def print
        @printer.print
      end
    end
  end
end
