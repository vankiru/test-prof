# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Example
        attr_reader :location, :group, :factories, :definitions

        def initialize(example, group)
          @name = example&.fetch(:name)
          @location = Location.new(example&.fetch(:location)&.split(":"))

          @group = group

          @factories = Set.new
          @definitions = Set.new

          group.examples << self if group
        end

        def to_s
          "example (#{@name}, #{location})"
        end
        alias_method :inspect, :to_s

        def to_block
          Block::It.new(@name, @location)
        end

        def ancestors
          @ancestors ||= [group] + group.ancestors
        end
      end
    end
  end
end
