# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Logger
        def initialize(code)
          @code = code
          @off = false
        end

        def off?
          @off
        end

        def replaced(line, before)
          return if off?

          puts <<~LOG
          # replace at #{line}
            - #{before.strip} 
            + #{@code[line].strip}
          LOG
        end

        def inserted(line)
          return if off?

          puts <<~LOG
          # insert at #{line}
            + #{@code[line].strip}
          LOG
        end

        def moved(from, to)
          return if off?

          start = from.is_a?(Range) ? from.last : from
          diff = to - start

          puts <<~LOG
          # move #{from} to #{to}
            +- #{@code[from + diff]}
          LOG
        end

        def duplicated(from, to)
          return if off?

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
