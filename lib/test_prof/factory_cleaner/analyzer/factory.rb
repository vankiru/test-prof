# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Factory
        attr_reader :name, :parent, :definition, :explicit_associations, :implicit_associations, :attributes, :examples

        attr_accessor :count

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
          definition&.location || 'n'
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
          params = implicit_associations.map do |name, association|
            "i:#{name} => #{association.location}"
          end

          params += explicit_associations.map do |name, association|
            "e:#{name} => #{association.location}"
          end

          params += attributes.map do |name, definition|
            "a:#{name} => #{definition.location}"
          end

          "f(#{name}, #{location}, #{params.join(", ")})"
        end
        alias_method :inspect, :to_s

        def short_desc
          "f(#{name}, #{location})"
        end

        def depth
          1 + explicit_associations.values.sum(&:depth) + implicit_associations.values.sum(&:depth)
        end
      end
    end
  end
end
