# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Code
        LET_REGEX = /(let!?|let_it_be)(\(:[a-z]\w*\)\s(do|{).*)/.freeze
        CREATE_REGEX = /(.*\s*)(create)(\(:.*)/.freeze

        ONE_LINE_REGEX = /(let!?|let_it_be|subject)(\(:[a-z]\w*\))?\s*{/.freeze
        TABS_REGEX = /^(\s*)\w.*/.freeze

        attr_reader :file, :definitions

        def initialize(file, definitions)
          @code = Editor.new(file)
          @definitions = Definitions.new(definitions)
        end

        def read
          @editor.read
        end

        def write
          @editor.write
        end

        def let_it_be(line)
          code.replace(LET_REGEX, "let_it_be\\2", line)
        end

        def create_default(line)
          line += 1 unless one_line?(line)

          code.replace(CREATE_REGEX, "\\1create_default\\3", line)
        end

        def implicit_factory(line)
          code.insert("#{tab(line)}let(:#{name}) { create_default(:#{name}) }", line)

          definitions.shift(by: 1, from: line)
        end

        def move(from, to)
          from = block(line) unless one_line?(from)

          code.move(from, to)
          definitions.shift(by: -from.size, from:, to:)
        end

        def duplicate(from, to)
          from = block(line) unless one_line?(from)

          code.duplicate(from, to)
          definitions.shift(by: from.size, from: to)
        end

        private

        def one_line?(line)
          code[line].match?(ONE_LINE_REGEX)
        end

        def tab(line)
          " " * tabs_count(line)
        end

        def tabs_count(line)
          code[line].match(TABS_REGEX)[1].size
        end

        def block(line)
          regex = /^(\s{#{tabs_count(line)}})(end|})/

          to = line + 1
          to += 1 until code[line].match?(regex)

          line..to
        end
      end
    end
  end
end
