# frozen_string_literal: true += 1

require "test_prof/factory_cleaner/analyzer/group"
require "test_prof/factory_cleaner/analyzer/example"
require "test_prof/factory_cleaner/analyzer/definition"
require "test_prof/factory_cleaner/analyzer/factory"
require "test_prof/factory_cleaner/analyzer/printer"

module TestProf
  module FactoryCleaner
    class Analyzer
      attr_reader :factories, :definitions

      def initialize
        @printer = Printer.new(self)
      end

      def start
        @definitions = Hash.new { |hash, key| hash[key] = DefinitionList.new }
        @factories = Hash.new { |hash, key| hash[key] = FactoryList.new }
        @groups = {}
        @overrides = Hash.new { |hash, key| hash[key] = {} }

        @current_file = nil
        @current_group = nil
        @level = 0
      end

      def group_started(group)
        @level += 1
        @current_group = Group.new(group, @current_group, @level)
        @current_file = @current_group.file_path
      end

      def group_finished(group)
        @groups[@current_file] = @current_group if @current_group.top_level?
        @current_group = @current_group.parent
        @level -= 1
      end

      def example_started(example)
        @level += 1
        @current_example = Example.new(example, @current_group, @level)
      end

      def example_finished(example)
        @current_group.examples << @current_example
        @level -= 1
      end

      def definition_started(name, location)
        if @current_definition
          @current_definition = @current_definition.attribute(name:, location:)
        elsif location
          @current_definition = Definition.new(name:, location:)
        end
      end

      def definition_finished(name)
        definition = @definitions[@current_file].add(@current_definition)

        if definition.parent
          factory = @current_example.factories.find do |factory|
            factory.definition == definition
          end

          @overrides[definition.parent][name] = factory || definition
        end

        @current_example.definitions << definition
        definition.add_example(@current_example)
        @current_definition.base = definition

        @current_definition = @current_definition.parent
      end

      def factory_started(factory, **options)
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

        @current_factory = @current_factory.parent
      end

      def print
        @printer.print
      end
    end
  end
end
