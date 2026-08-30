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

        def after_patches_line_number
          @dependencies.map(&:line_number).max || line_number
        end
        alias_method :to_line, :after_patches_line_number
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
          #if @options[:order].zero?
            #code.move(line_number, to_line)
          #else
            #code.duplicate(line_number, to_line)
          #end

          return if object.count == 1

          code.create_default(line_number) if options[:default]
          code.let_it_be(line_number)
          code.move(line_number, to_line)
        end

        def to_line
          if after_patches_line_number > line_number
            after_patches_line_number
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

        def type
          "i"
        end

        def apply(code)
          code.implicit_factory(factory.name, insert_line_number, first: !plan.before_all?)
          plan.before_all!
        end

        def insert_line_number
          if plan.before_all?
            @line_number = plan.befor_all_last_line + 1
          else
            first_nested = options[:group].first_nested.line_number - 1
            plan.before_all_last_line = first_nested + 1
            @line_number = first_nested + 1
            first_nested
          end
        end
      end

      class SuggestedDefinitionPatch < Patch
        alias_method :factory, :object

        def type
          "i"
        end

        def definition
          options[:definition]
        end

        def apply(code)
          code.definition_to_factory(factory.name, line_number)
          #code.move(line)
        end

        def line_number
          definition.line_number
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
