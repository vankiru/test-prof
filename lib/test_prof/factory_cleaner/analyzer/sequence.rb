# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Group
        attr_reader :parent

        def initialize(group, parent, level)
          @name = group&.fetch(:name)
          @location = group&.fetch(:location)
          @parent = parent
          @level = level
        end

        def inspect
          "group (#{name}, #{level})"
        end
      end

      class Example
        attr_reader :group

        def initialize(example, group, level)
          @name = example&.fetch(:name)
          @location = example&.fetch(:location)
          @group = group
          @level = level
        end

        def inspect
          "example (#{name}, #{level})"
        end
      end

      class Factory
        attr_reader :name, :parent

        def initialize(name, let, parent = nil)
          @name = name
          @let = let
          @parent = parent
          @associations = []
        end

        def association(name, let)
          let = nil if let == @let
          association = Factory.new(name, let, self)

          @associations << association
          association
        end

        def inspect
          "factory (#{@name}, #{let.name}, #{@associations.map(&:name)})"
        end
      end

      class Let
        attr_reader :parent, :name

        def initialize(name, parent = nil)
          @name = name
          @location = nil
          @parent = parent
          @dependencies = []
        end

        def dependency(name)
          dependency = Let.new(name, self)

          @dependencies << dependency
          dependency
        end

        def inspect
          "let (#{@name}, #{@dependencies.count})"
        end
      end
    end
  end
end
