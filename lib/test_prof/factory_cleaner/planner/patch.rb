# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Patch
        attr_reader :object, :dependencies, :options
        attr_accessor :plan

        def initialize(object, dependencies, **options)
          @plan = plan
          @object = object
          @dependencies = dependencies
          @options = options
        end

        def name
          object.name
        end

        def line_number
          object.location.line_number
        end

        def explicit_factory?
          false
        end

        def to_s
          "#{type}(#{object}, (#{line_number}:#{to_line}), #{dependencies.map(&:name).join("-")}, #{@options})"
        end
        alias_method :inspect, :to_s

        private

        def last_patch
          #@dependencies.max_by(&:line_number)
          @dependencies.max_by { |dependency| dependency.line_number || -1 }
        end

        def last_patch_line_number
          last_patch&.line_number || line_number
        end
        alias_method :to_line, :last_patch_line_number
      end

      class ExplicitFactoryPatch < Patch
        alias_method :factory, :object

        def type
          "e"
        end

        def explicit_factory?
          true
        end

        def apply(code)
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

        def same_group?
        end

        def after_line
          if last_patch_line_number > line_number
            last_patch_line_number
          else
            line_number
          end
        end

        def default!
          options[:default] = true
        end
      end

      class ImplicitFactoryPatch < Patch
        alias_method :factory, :object
        attr_reader :line_number

        def type
          "i"
        end

        def apply(code)
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

      class SuggestedDefinitionPatch < Patch
        alias_method :factory, :object

        def type
          "s"
        end

        def definition
          options[:definition]
        end

        def apply(code)
          code.definition_to_factory(factory.name, line_number)
        end

        def line_number
          definition.location.line_number
        end

        def default!
          options[:default] = true
        end
      end

      class AttributePatch < Patch
        alias_method :definition, :object

        def type
          "a"
        end

        def apply(code)
          code.let_it_be(line_number)
        end
      end
    end
  end
end
