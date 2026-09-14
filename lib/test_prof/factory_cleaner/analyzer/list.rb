# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class FactoryList
        include Enumerable

        def initialize
          @factories = {}
          @top_level = Set.new
        end

        def add(factory)
          @factories[factory] ||= factory
          @factories[factory].count += 1

          if @factories[factory].top_level?
            @top_level << @factories[factory]
          end

          @factories[factory]
        end

        def each(&block)
          @factories.each_key(&block)
        end

        def top_level
          @top_level_factories ||= @top_level.each_with_object({}) do |factory, hash|
            hash[factory.name] ||= {}
            hash[factory.name][factory.definition] ||= []
            hash[factory.name][factory.definition] << factory
          end
        end

        def depth_order
          @top_level.uniq { |factory| factory.name }.sort_by(&:depth).map(&:name)
        end
      end

      class DefinitionList
        include Enumerable

        def initialize
          @definitions = {}
          @top_level = Set.new
        end

        def add(definition)
          @definitions[definition] ||= definition
          @definitions[definition].count += 1

          if @definitions[definition].top_level?
            @top_level << @definitions[definition]
          end

          @definitions[definition]
        end

        def each(&block)
          @definitions.each_key(&block)
        end
      end
    end
  end
end
