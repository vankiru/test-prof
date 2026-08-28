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

        def object_defined?
          true
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
          if @dependencies.any?
            @dependencies.map(&:line_number).max
          else
            line_number
          end
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
          if @options[:order].zero?
            code.move(line_number, to_line)
          else
            code.duplicate(line_number, to_line)
          end

          if object.count > 1
            code.create_default(to_line)
            code.let_it_be(to_line)
          end
        end

        def to_line
          if after_patches_line_number > line_number
            after_patches_line_number
          else
            line_number
          end
        end
      end

      class ImplicitFactoryPatch < Patch
        alias_method :factory, :object

        def type
          "i"
        end

        def apply(code)
          code.implicit_factory(factory.name, line_number, create_default?)
        end

        def line_number
          return defined_patches_line_number if defined_patches_line_number

          factory.examples.first.ancestors.last.line_number + 1
        end

        def defined_patches_line_number
          @dependencies.select(&:object_defined?).map(&:line_number).max
        end

        def object_defined?
          false
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
