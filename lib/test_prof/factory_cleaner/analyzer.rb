# frozen_string_literal: true += 1

require "test_prof/factory_cleaner/analyzer/group"
require "test_prof/factory_cleaner/analyzer/example"
require "test_prof/factory_cleaner/analyzer/definition"
require "test_prof/factory_cleaner/analyzer/factory"
require "test_prof/factory_cleaner/analyzer/printer"

module TestProf
  module FactoryCleaner
    class Analyzer
      attr_reader :factories, :definitions, :groups

      def initialize
        @printer = Printer.new(self)
      end

      def start
        #@definitions = Hash.new { |hash, key| hash[key] = DefinitionList.new }
        #@factories = Hash.new { |hash, key| hash[key] = FactoryList.new }
        #@groups = {}
        #@overrides = Hash.new { |hash, key| hash[key] = {} }

        @current_group = nil
        @current_block = nil

        @specs = []
        @level = 0
      end

      def group_started(group)
        @level += 1
        @current_group = Group.new(group, @current_group, @level)
      end

      def group_finished(group)
        @specs << @current_group if @current_group.top_level?
        @current_group = @current_group.parent
        @level -= 1
      end

      def example_started(example)
        @current_example = Example.new(example, @current_group)
      end

      def example_finished(example)
        @current_group.examples << @current_example
        @current_example = nil
      end

      def let_started(name, location)
        @current_block = Block::Let.new(name, location)
      end

      def let_finished(name)
        @current_block = nil
      end

      def factory_started(name, **options)
      end

      def factory_finished(name)
      end


      def definition_started(name, location)
        #puts "= definition started #{name}:#{location}"

        if @current_definition
          @current_definition = @current_definition.attribute(name:, location:)
        elsif location
          @current_definition = Definition.new(name:, location:)
        end
      end

      def definition_finished(name)
        definition = @definitions[@current_file].add(@current_definition)

        if @current_definition.parent
          factory = @current_example.factories.find do |factory|
            factory.definition == definition
          end

          @overrides[@current_definition.parent][name] = factory || definition
        end
        #puts " $ #{name} - #{@current_definition.parent} - #{@overrides[@current_definition.parent]}"

        @current_example.definitions << definition
        @current_group.definitions << definition
        definition.add_example(@current_example)

        @current_definition.base = definition
        @current_definition.base.defines_factory = definition.defines_factory

        #puts " $ #{name} - #{@current_definition} - #{@current_definition.parent} - #{@current_definition.defines_factory} - #{@current_definition.defines_through_factory?}"
        #puts " $ #{name} - #{definition} - #{definition.parent} - #{definition.defines_factory} - #{definition.defines_through_factory?}"

        @current_definition = @current_definition.parent
        #puts "= definition finished #{name}"
      end

      def factory_started(factory, **options)
        #puts "+ factory started #{factory}"
        params = {
          name: factory,
          definition: @current_definition,
          overrides: @overrides[@current_definition]
        }

        if @current_factory
          @current_factory = @current_factory.association(params)
        else
          @current_factory = Factory.new(params)
        end
      end

      def factory_finished(factory)
        factory = @factories[@current_file].add(@current_factory)

        @current_example.factories << factory
        @current_group.factories << factory

        factory.add_example(@current_example)
        @current_factory.base = factory
        @current_definition&.defines_factory = true

        @current_factory = @current_factory.parent
        #puts "+ factory finished #{factory}}"
      end

      def print
        @printer.print
      end
    end
  end
end
