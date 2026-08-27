# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        attr_reader :name, :parent, :definition, :explicit_associations, :implicit_associations, :attributes

        attr_accessor :count, :base

        def initialize(params)
          @name = params[:name]
          @parent = params[:parent]
          @definition = params[:definition]

          @attributes = {}
          @explicit_associations = {}
          @implicit_associations = {}

          @examples = Set.new
          @count = 0

          params[:overrides]&.each do |key, value|
            if value.is_a?(Factory)
              @explicit_associations[key] = value
            else
              @attributes[key] = value
            end
          end
        end

        def location
          definition&.location
        end

        def association(params)
          if @definition.nil? || @definition == params[:definition]
            params[:definition] = nil
            params[:overrides] = nil
          end

          name = params[:name]
          factory = Factory.new(parent: self, **params)

          if factory.explicit?
            @explicit_associations[name] = factory
          else
            @implicit_associations[name] = factory
          end
        end

        def explicit?
          !!definition
        end
        
        def top_level?
          parent.nil?
        end

        def eql?(factory)
          factory.is_a?(Factory) &&
            name == factory.name &&
            definition == factory.definition &&
            explicit_associations == factory.explicit_associations &&
            implicit_associations == factory.implicit_associations &&
            attributes == factory.attributes
        end
        alias_method :==, :eql?

        def hash
          @name.hash
        end

        def to_s
          parts = ["#{name}:#{location&.line_number || "n"}"]

          implicit_associations.each do |name, association|
            parts << "i:#{association}"
          end

          explicit_associations.map do |name, association|
            parts << "e:#{association}"
          end

          attributes.map do |name, attribute|
            parts << "a:#{attribute}"
          end

          "f(#{parts.join(", ")})"
        end
        alias_method :inspect, :to_s

        def depth
          1 + explicit_associations.values.sum(&:depth) + implicit_associations.values.sum(&:depth)
        end

        def add_example(example)
          @examples << example
        end

        def examples
          @examples.any? ? @examples : base&.examples
        end
      end

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
    end
  end
end
