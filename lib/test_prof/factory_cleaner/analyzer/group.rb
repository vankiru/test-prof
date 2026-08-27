# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Group
        attr_reader :parent, :examples, :factories, :children

        def initialize(group, parent, level)
          @name = group&.fetch(:name)
          @file_path, @line_number = group&.fetch(:location)
          @parent = parent
          @level = level
          @examples = []
          @factories = []
          @children = []

          parent.children << self if parent
        end

        def location
          "#{@file_path}:#{@line_number}"
        end

        def line_number
          @line_number.to_i
        end

        def to_s
          "group (#{@name}, #{@level} #{location})"
        end
        alias_method :inspect, :to_s

        def top_level_factories
          factories.select(&:top_level?)
        end

        def ancestors
          @ancestors ||= parent.nil? ? [] : ([parent] + parent.ancestors)
        end
      end
    end
  end
end
