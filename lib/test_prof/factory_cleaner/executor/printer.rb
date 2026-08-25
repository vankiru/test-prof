# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Printer
        def initialize(executor)
          @executor = executor
        end

        def print
          puts "=== Executor ==="
        end
      end
    end
  end
end
