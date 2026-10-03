# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Executor
      class Change
        attr_reader :code, :patch

        def initialize(code, patch)
          @code = code
          @patch = patch
        end
      end

      class ExplicitFactoryChange < Change
        def apply
          #if @options[:order].zero? && same_group?
            #code.move(line_number, after_line)
          #else
            #code.duplicate(line_number, after_line)
          #end
          code.duplicate(line_number, after_line)

          return if object.count == 1

          code.create_default(line_number) if options[:default]
          code.let_it_be(line_number)
        end

        def after_line
          if last_patch_line_number > line_number
            last_patch_line_number
          else
            line_number
          end
        end
      end

      class ImplicitFactoryChange < Change
        def apply
          code.implicit_factory(factory.name, insert_line_number, !plan.before_all?)
          plan.before_all!
        end

        def insert_line_number
          if plan.before_all?
            @line_number = plan.before_all_last_line
          else
            first_nested = (options[:group]&.line_number || 5) + 1

            @line_number = first_nested + 1
            plan.before_all_last_line = @line_number

            first_nested
          end
        end
      end

      class SuggestedDefinitionChange < Change
        def apply
          code.definition_to_factory(factory.name, line_number)
        end

        def line_number
          definition.location.line_number
        end
      end

      class AttributeChange < Change
        def apply
          code.let_it_be(line_number)
        end
      end
      end
    end
  end
end
