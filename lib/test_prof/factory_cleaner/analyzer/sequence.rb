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
        attr_reader :name, :parent, :definition

        def initialize(name, definition, parent = nil)
          @name = name
          @definition = definition
          @parent = parent
          @associations = []
        end

        def association(name, definition)
          definition = nil if definition == @definition
          association = Factory.new(name, definition, self)

          @associations << association
          association
        end

        def eql?(factory)
          factory.is_a?(Factory) && @name == factory.name && @definition.eql?(factory.definition)
        end

        def hash
          @name.hash
        end

        def inspect
          "factory (#{@name}, #{@definition&.location&.join(':')})"
        end
      end

      class Let
        attr_reader :parent, :name, :location

        def initialize(name, location, parent = nil)
          @name = name
          @location = location
          @parent = parent
          @dependencies = []
        end

        def dependency(name, location)
          dependency = Let.new(name, location, self)

          @dependencies << dependency
          dependency
        end

        def eql?(let)
          let.is_a?(Let) && let.location == @location
        end

        def hash
          @name.hash
        end

        def inspect
          "let (#{@name}, #{@location.join(':')})"
        end
      end

      class Set
        def initialize
          @data = {}
        end

        def <<(item)
          @data[item] ||= 0
          @data[item] += 1
        end

        def inspect
          @data
        end
      end
    end
  end
end
