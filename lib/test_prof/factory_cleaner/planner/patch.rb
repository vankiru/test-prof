# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Patch
        attr_reader :object, :dependencies, :options

        def initialize(object, dependencies, **options)
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
          "#{type}(#{object}, #{dependencies.map(&:name).join("-")}, #{@options})"
        end
        alias_method :inspect, :to_s
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
          if @options[:order].zero?
            code.move(line_number, to)
          else
            code.duplicate(line_number, to)
          end

          if object.count > 1
            code.create_default(to)
            code.let_it_be(to)
          end
        end
      end

      class ImplicitFactoryPatch < Patch
        alias_method :factory, :object

        def type
          "i"
        end

        def apply(code)
          code.implicit_factory(line_number)
        end

        def line_number
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
