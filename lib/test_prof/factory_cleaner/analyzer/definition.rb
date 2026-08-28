# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Definition
        attr_reader :name, :parent, :attributes

        attr_accessor :count, :base

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

      class Location
        attr_reader :file_path, :line_number, :original_line_number

        def initialize(file_path, line_number)
          @file_path = file_path
          @original_line_number = line_number.to_i
          @line_number = line_number.to_i
        end

        def shift(by)
          @line_number += by
        end

        def to_s
          string = "#{@file_path}:#{@line_number}"
          string += "(#{@original_line_number})" if shifted?

          string
        end

        def eql?(location)
          @file_path == location.file_path && @line_number == location.line_number
        end
        alias_method :==, :eql?

        def hash
          to_s.hash
        end

        private

        def shifted?
          @original_line_number != @line_number
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
