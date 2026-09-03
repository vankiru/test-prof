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
            - #{before.rstrip} 
            + #{@code[line].rstrip}
          LOG
        end

        def inserted(line)
          return if off?

          puts <<~LOG
          # insert at #{line}
            + #{@code[line].rstrip}
          LOG
        end

        def moved(from, to)
          return if off?

          start = from.is_a?(Range) ? from.last : from
          diff = to - start

          puts <<~LOG
          # move #{from} to #{to}
            > #{@code[to - 2]}
            + #{@code[to - 1]}
          LOG
        end

        def duplicated(from, to)
          return if off?

          start = from.is_a?(Range) ? from.first : from
          diff = to - start

          puts <<~LOG
          # duplicate #{from} to #{to}
            + #{@code[to].rstrip}
          LOG
        end

        def tabed(range, as)
          return if off?

          puts <<~LOG
          # tab as #{as}
            > #{@code[as].rstrip}
            + #{@code[range.first].rstrip}
          LOG
        end
      end
    end
  end
end
