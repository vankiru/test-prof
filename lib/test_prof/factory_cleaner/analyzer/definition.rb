# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Definition
        attr_reader :name, :parent, :location, :attributes, :examples

        def initialize(params)
          @name = params[:name]
          @parent = params[:parent]
          @location = Location.new(*params[:location])

          @attributes = {}
          @examples = Set.new
        end

        def attribute(params)
          @attributes[params[:name]] = Definition.new(parent: self, **params)
        end

        def to_s
          "d(#{@name}, #{location})"
        end
        alias_method :inspect, :to_s
        alias_method :short_desc, :to_s

        def eql?(definition)
          definition.is_a?(Definition) && definition.location == location
        end
        alias_method :==, :eql?

        def hash
          @name.hash
        end
      end

      class Location
        attr_reader :file_path, :line_number

        def initialize(file_path, line_number)
          @file_path = file_path
          @original_line_number = line_number
          @line_number = line_number
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
    end
  end
end
