# frozen_string_literal: true

class Range
  def +(by)
    (first + by)..(last + by)
  end

  def -(by)
    (first - by)..(last - by)
  end
end

module TestProf
  module FactoryCleaner
    class Executor
      class Editor
        def initialize(file)
          @file = file
        end

        def read
          @code = File.readlines(@file)
        end

        def write
          File.write(@file, @code.join)
        end

        def [](line)
          @code[line - 1]
        end

        def insert(code, line)
          if code.is_a?(Array)
            @code.insert(line, *code)
          else
            @code.insert(line, code)
          end
        end

        def delete(line)
          @code.slice!(line - 1)
        end

        def copy(line)
          @code[line - 1]
        end

        def replace(regex, with, line)
          @code[line - 1].sub!(regex, with)
        end

        def move(from, to)
          to -= from.size if from.is_a?(Range)

          insert(delete(from), to)
        end

        def duplicate(from, to)
          insert(copy(from), to)
        end
      end
    end
  end
end
