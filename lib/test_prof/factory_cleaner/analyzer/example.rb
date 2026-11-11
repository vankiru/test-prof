# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Example
        attr_reader :location, :group, :factories

        def initialize(example, group)
          @name = example[:name]
          @location = Location.new(example[:location])

          @group = group
          @factories = Set.new

          group.examples << self if group
        end

        def to_s
          "example (#{@name}, #{@location})"
        end
        alias_method :inspect, :to_s

        def as_block
          Block::Example.new(@name, @location)
        end

        def ancestors
          @ancestors ||= [group] + group.ancestors
        end
      end
    end
  end
end
