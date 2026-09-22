# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Definition
        attr_reader :name, :parent, :attributes, :location

        attr_accessor :count

        def initialize(params)
          @name = params[:name]
          @parent = params[:parent]
          @location = Location.new(*params[:location])

          @attributes = {}
          @examples = Set.new
          @count = 0
        end

        def top_level?
          parent.nil?
        end

        def to_s
          "d(#{name}:#{location.line_number})"
        end
        alias_method :inspect, :to_s

        def eql?(definition)
          definition.is_a?(Definition) && definition.location == location
        end
        alias_method :==, :eql?

        def attribute(params)
          @attributes[params[:name]] = Definition.new(parent: self, **params)
        end

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
      end
    end
  end
end
