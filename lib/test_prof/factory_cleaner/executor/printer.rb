# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Printer
        def initialize(code)
          @code = code
        end

        def print
          puts "=== Executor ==="
        end

        def replaced(line, before)
          puts <<~LOG
          # replace at #{line}
            - #{before.strip} 
            + #{@code[line].strip}
          LOG
        end

        def inserted(line)
          puts <<~LOG
          # insert at #{line}
            + #{@code[line].strip}
          LOG
        end

        def moved(from, to)
          puts <<~LOG
          # move #{from} to #{to}
            +- #{@code[from + to]}
          LOG
        end

        def duplicated(from, to)
          puts <<~LOG
          # duplicate #{from} to #{to}
            + #{@code[from + to]}
          LOG
        end
      end
    end
  end
end
