# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        class Template
          attr_reader :block, :type, :associations

          def initialize(name:, parent:, block:, **options)
            @name = name
            @parent = parent
            @block = block
            @options = options
            @associations = []

            parent.associations << self if parent
          end

          def definition
            block unless parent.block == block
          end

          def finalize(spec)
            association_types = associations.map(&:type)

            @type = Factory::Type.new(
              name:
              associations: association_types
            )

            association_types.each do |type|
              type.parent = @type
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

            @current_example.definitions << definition
            @current_group.definitions << definition
            definition.add_example(@current_example)

            @current_definition.base = definition
            @current_definition.base.defines_factory = definition.defines_factory

            @current_definition = @current_definition.parent
          end

          def factory_started(factory, **options)
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
          end
        end
      end
    end
  end
end
