# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Group
        attr_reader :location, :parent, :groups, :examples, :factories, :definitions

        def initialize(group, parent, level)
          @name = group&.fetch(:name)
          @location = Location.new(group&.fetch(:location)&.split(":"))

          @parent = parent
          @level = level

          @examples = []
          @groups = []

          @factories = []
          @definitions = []

          parent.groups << self if parent
        end

        def to_s
          "group (#{@name}, #{location})"
        end
        alias_method :inspect, :to_s

        def ancestors
          @ancestors ||= top_level? ? [] : ([parent] + parent.ancestors)
        end

        def top_level?
          parent.nil?
        end
      end
    end
  end
end
