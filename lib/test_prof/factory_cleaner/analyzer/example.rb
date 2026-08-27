# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Example
        attr_reader :group, :factories, :definitions

        def initialize(example, group, level)
          @name = example&.fetch(:name)
          @file_path, @line_number = example&.fetch(:location)
          @group = group
          @level = level

          @factories = Set.new
          @definitions = Set.new

          group.children << self if group
        end

        def location
          "#{@file_path}:#{@line_number}"
        end

        def line_number
          @line_number.to_i
        end

        def to_s
          "example (#{@name}, #{@level} #{location})"
        end
        alias_method :inspect, :to_s

        def ancestors
          @ancestors ||= [group] + group.ancestors
        end
      end
    end
  end
end
