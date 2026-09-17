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
        @current_spec = nil
        @current_group = nil
        @current_block = nil

        @specs = []
        @level = 0
      end

      def group_started(group)
        @level += 1
        @current_group = Group.new(group, @current_group, @level)

        if @current_group.top_level?
          @current_spec = @current_group
          @specs << @current_spec
        end
      end

      def group_finished(group)
        @current_group = @current_group.parent
        @level -= 1
      end

      def example_started(example)
        @current_example = Example.new(example, @current_group)
        @current_block = @current_example.to_block
      end

      def example_finished(example)
        @current_group.examples << @current_example
        @current_example = nil
        @current_block = nil
      end

      def let_started(name, location)
        @current_block = Block::Let.new(name, location)
      end

      def let_finished(name)
        @current_block = nil
      end

      def factory_started(name, options)
        @current_template = Factory::Template.new(
          name:,
          parent: @current_template,
          block: @current_block,
          **options
        )
      end

      def factory_finished(name)
        factory = @current_template.finalize(@current_spec)

        @current_example.factories << factory
        @current_group.factories << factory

        @current_template = @current_template.parent
      end

      def print
        @printer.print
      end
    end
  end
end
