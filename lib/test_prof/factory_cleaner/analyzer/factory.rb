# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        attr_reader :name, :parent, :definition, :explicit_associations, :implicit_associations, :attributes

        attr_accessor :count, :base

        def initialize(name, parent, options)
        end

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
            #elsif value.defines_through_factory?
              #@implicit_associations[key] = value
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

        def shared_example?
          location && location.file_path.start_with?("/app/spec/support/shared_")
        end

        def defined_in?(group)
          definition&.defined_in?(group)
        end

        def definition_started(name, location)
          #puts "= definition started #{name}:#{location}"

          if @current_definition
            @current_definition = @current_definition.attribute(name:, location:)
          elsif location
            @current_definition = Definition.new(name:, location:)
          end
        end

        def definition_finished(name)
          definition = @definitions[@current_file].add(@current_definition)

          if @current_definition.parent
            factory = @current_example.factories.find do |factory|
              factory.definition == definition
            end

            @overrides[@current_definition.parent][name] = factory || definition
          end
          #puts " $ #{name} - #{@current_definition.parent} - #{@overrides[@current_definition.parent]}"

          @current_example.definitions << definition
          @current_group.definitions << definition
          definition.add_example(@current_example)

          @current_definition.base = definition
          @current_definition.base.defines_factory = definition.defines_factory

          #puts " $ #{name} - #{@current_definition} - #{@current_definition.parent} - #{@current_definition.defines_factory} - #{@current_definition.defines_through_factory?}"
          #puts " $ #{name} - #{definition} - #{definition.parent} - #{definition.defines_factory} - #{definition.defines_through_factory?}"

          @current_definition = @current_definition.parent
          #puts "= definition finished #{name}"
        end

        def factory_started(factory, **options)
          #puts "+ factory started #{factory}"
          params = {
            name: factory,
            definition: @current_definition,
            overrides: @overrides[@current_definition]
          }

          if @current_factory
            @current_factory = @current_factory.association(params)
          else
            @current_factory = Factory.new(params)
          end
        end

        def factory_finished(factory)
          factory = @factories[@current_file].add(@current_factory)

          @current_example.factories << factory
          @current_group.factories << factory

          factory.add_example(@current_example)
          @current_factory.base = factory
          @current_definition&.defines_factory = true

          @current_factory = @current_factory.parent
          #puts "+ factory finished #{factory}}"
        end
      end
    end
  end
end
