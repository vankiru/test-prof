# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        class Type
          attr_reader :block, :associations

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
            build_type(spec)
            build_instance(spec)
          end

          private

          def build_type(spec)
            association_types = associations.map(&:type)

            @type = Factory::Type.new(
              name:
              definition:,
              associations: association_types
            )

            association_types.each do |type|
              type.parent = @type
            end

            spec.factory_types << @type
          end

          def build_instance
            @instance = Factory::Instance.new(@type)
          end
        end
      end
    end
  end
end
