# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        class Type
          attr_reader :name

          def initialize(params)
            @name = params[:name]
            @parent = params[:parent]
            @definition = params[:definition]

            @attributes = {}
            @associations = {}

            @examples = Set.new

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

            associations.each do |name, association|
              parts << "#{association.index}:#{association}"
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
        end
      end
    end
  end
end
