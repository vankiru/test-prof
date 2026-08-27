# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Logger
        def initialize(code)
          @code = code
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
          start = from.is_a?(Range) ? from.last : from
          diff = to - start

          puts <<~LOG
          # move #{from} to #{to}
            +- #{@code[from + diff]}
          LOG
        end

        def duplicated(from, to)
          start = from.is_a?(Range) ? from.first : from
          diff = to - start

          puts <<~LOG
          # duplicate #{from} to #{to}
            + #{@code[from + diff]}
          LOG
        end
      end
    end
  end
end
