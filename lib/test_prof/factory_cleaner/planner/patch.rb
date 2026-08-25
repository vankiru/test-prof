# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Patch
        attr_reader :object, :dependencies

        def initialize(object, dependencies, **options)
          @object = object
          @dependencies = dependencies
          @options = options
        end

        def name
          object.name
        end

        def explicit_factory?
          false
        end

        def to_s
          "#{type}(#{object.short_desc}, #{dependencies.map(&:name).join("-")}, #{@options})"
        end
        alias_method :inspect, :to_s
      end

      class ExplicitFactoryPatch < Patch
        alias_method :factory, :object

        def order
          @options[:order]
        end

        def explicit_factory?
          true
        end

        def type
          "e"
        end
      end

      class ImplicitFactoryPatch < Patch
        alias_method :factory, :object

        def type
          "i"
        end
      end

      class AttributePatch < Patch
        alias_method :definition, :object

        def type
          "a"
        end
      end
    end
  end
end
