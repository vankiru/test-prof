# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Definition
        attr_reader :name, :parent, :attributes

        attr_accessor :count, :base, :defines_factory

        def initialize(params)
          @name = params[:name]
          @parent = params[:parent]
          @location = Location.new(*params[:location])

          @attributes = {}
          @examples = Set.new
          @count = 0

          @defines_factory = false
        end

        def defines_through_factory?
          base&.defines_factory || base&.parent&.defines_through_factory?
          #@defines_factory || @parent&.defines_through_factory?
        end

        def top_level?
          parent.nil?
        end

        def attribute(params)
          @attributes[params[:name]] = Definition.new(parent: self, **params)
        end

        def to_s
          "d(#{name}:#{location.line_number})"
        end
        alias_method :inspect, :to_s

        def eql?(definition)
          definition.is_a?(Definition) && definition.location == location
        end
        alias_method :==, :eql?

        def hash
          @name.hash
        end

        def defined_in?(group)
          child = group.children.first
          location.line_number.between?(group.line_number, child.line_number)
        end

        def add_example(example)
          @examples << example
        end

        def examples
          @examples.any? ? @examples : base&.examples
        end

        def location
          if base.nil? || base.object_id == self.object_id
            @location
          else
            base.location
          end
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
