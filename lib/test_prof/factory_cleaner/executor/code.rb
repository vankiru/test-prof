# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Code
        LET_REGEX = /(let!?|let_it_be)(\(:[a-z]\w*\)\s(do|{).*)/.freeze
        CREATE_REGEX = /(.*\s*)(create)(\(:.*)/.freeze
        DEFINITION_REGEX = /(let!?|let_it_be|subject)(\(:[a-z]\w*\))?\s*{.*}/.freeze
        CONTEXT_REGEX = /(context|describe)\s*\".*"/.freeze

        ONE_LINE_REGEX = /(let!?|let_it_be|subject)(\(:[a-z]\w*\))?\s*{/.freeze
        TABS_REGEX = /^(\s*)((\w|}).*)/.freeze

        attr_reader :file, :definitions, :code

        def initialize(file, definitions)
          @code = Editor.new(file)
          @definitions = Definitions.new(definitions)
          @logger = Logger.new(@code)
          @counter = 0
        end

        def read
          @code.read
        end

        def write
          @code.write
        end

        def let_it_be(line)
          before = @code[line].dup
          code.replace(LET_REGEX, "let_it_be\\2", line)
          @logger.replaced(line, before)
        end

        def create_default(line)
          before = @code[line].dup
          line += 1 unless one_line?(line)

          code.replace(CREATE_REGEX, "\\1create_default\\3", line)
          @logger.replaced(line, before)
        end

        def definition_to_factory(name, line)
          before = @code[line].dup

          if one_line?(line)
            code.replace(DEFINITION_REGEX, "let_it_be\\2 { create_default(:#{name})}", line)
          else
            line += 1
            code.delete(line)
            code.insert("create_default(:#{name})", line)
          end

          @logger.replaced(line, before)
        end

        def implicit_factory(name, line, first)
          if first
            code.insert("before_all do\n", line)
            code.insert("  create_default(:#{name})\n", line + 1)
            code.insert("end\n", line + 2)
            code.insert("\n", line + 3)

            definitions.shift(by: 4, from: line)
          else
            code.insert("create_default(:#{name})\n", line)
            definitions.shift(by: 1, from: line)
          end

          @logger.inserted(line)
        end

        def move(from, after)
          return if from == after

          after += to_range(after).size
          range = to_range(from)

          tab(range, after)
          code.move(range, after)

          # shift up
          definitions.shift(by: -range.size, from: range.last + 1, to: after + range.size - 2)
          # shift down
          definitions.shift(by: after - range.first - 1, from: range.first, to: range.last)

          @logger.moved(range, after)
        end

        def duplicate(from, after)
          return if from == after

          range = to_range(from)
          tab(range, after)
          code.duplicate(range, after)

          definitions.shift(by: range.size, from: after - 1)

          @logger.duplicated(from, after)
        end

        def tab(range, as)
          as -= 1 while empty_line?(as)
          tabs = tabs_count(as)

          range.each do |line|
            code.replace(TABS_REGEX, "#{" " * tabs}\\2", line)
          end

          @logger.tabed(range, as)
        end

        private

        def one_line?(line)
          code[line].match?(ONE_LINE_REGEX)
        end

        def empty_line?(line)
          code[line] == "\n"
        end

        def to_range(from)
          if one_line?(from)
            from..from
          else
            block(from) 
          end
        end

        def block(line)
          regex = /^(\s{#{tabs_count(line)}})(end|})/

          to = line + 1
          until code[to].match?(regex)
            to += 1 
          end

          line..to
        end

        def tabs_count(line)
          match = code[line].match(TABS_REGEX)
          match ? match[1].size : 0
        end
      end
    end
  end
end
