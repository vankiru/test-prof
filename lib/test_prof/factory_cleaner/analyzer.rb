# frozen_string_literal: true

require "test_prof/factory_cleaner/analyzer/group"
require "test_prof/factory_cleaner/analyzer/example"
require "test_prof/factory_cleaner/analyzer/definition"
require "test_prof/factory_cleaner/analyzer/factory"
require "test_prof/factory_cleaner/analyzer/stats"
require "test_prof/factory_cleaner/analyzer/printer"

module TestProf
  module FactoryCleaner
    class Analyzer
      attr_reader :factories

      def initialize
        @printer = Printer.new(self)
      end

      def start
        @factories = {}
        @overrides = {}

        @root = Group.new(nil, nil, 0)
        @current_group = @root
        @current_example = nil
        @current_sequence = nil

        @level = 0
      end

      def group_started(group)
        @level += 1
        @current_group = Group.new(group, @current_group, @level)
      end

      def group_finished(group)
        @current_group = @current_group.parent
        @level -= 1
      end

      def example_started(example)
        @level += 1
        @current_example = Example.new(example, @current_group, @level)
      end

      def example_finished(example)
        @level -= 1
      end

      def definition_started(name, location)
        @level += 1

        #puts "+ definition start #{name} - #{@level}"
        params = {
          name:,
          location:,
        }

        if @current_definition
          @current_definition = @current_definition.attribute(params)
        elsif location
          @current_definition = Definition.new(params)
        end
      end

      def definition_finished(name)
        if @current_definition
          factory = @current_example.factories.find do |factory|
            factory.definition == @current_definition
          end

          @overrides[@level] ||= {}
          @overrides[@level][name] = factory || @current_definition
          #puts "+ definition finish #{name} - #{@level} - #{@overrides[@level][name].inspect}"

          @overrides.delete(@level + 1)
        end

        @current_example.definitions << @current_definition
        @current_definition.examples << @current_example

        @current_definition = @current_definition&.parent
        @level -= 1
      end

      def factory_started(factory, **options)
        @level += 1

        #puts "= factory start #{factory} - #{@level} - #{@overrides[@level]&.map(&:inspect)}"
        params = {
          name: factory,
          definition: @current_definition,
          overrides: @overrides.delete(@level)
        }

        if @current_factory
          @current_factory = @current_factory.association(params)
        else
          @current_factory = Factory.new(params)
        end
      end

      def factory_finished(factory)
        #puts "= factory finish #{factory} - #{@level}"

        @current_example.factories << @current_factory
        @current_factory.examples << @current_example

        unless @current_factory.parent
          @factories[factory] ||= Stats.new
          @factories[factory] << @current_factory
        end

        @current_factory = @current_factory&.parent
        @level -= 1
      end

      def print
        @printer.print
      end
    end
  end
end
