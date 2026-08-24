# frozen_string_literal: true

require "test_prof/factory_cleaner/analyzer/sequence"
require "test_prof/factory_cleaner/analyzer/printer"

module TestProf
  module FactoryCleaner
    class Analyzer
      attr_reader :factories, :lets

      def initialize
        @printer = Printer.new(self)
      end

      def start
        @factories = {}
        @lets = {}

        @current_group = Group.new(nil, nil, 0)
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

      def let_started(name)
        if @current_let
          @current_let = @current_let.dependency(name)
        else
          @current_let = Let.new(name)
        end
      end

      def let_finished(name)
        @lets[name] ||= []
        @lets[name] << @current_let

        @currrent_let = @current_let&.parent
      end

      def factory_started(factory, **options)
        if @current_factory
          @current_factory = @current_factory.association(factory, @current_let)
        else
          @current_factory = Factory.new(factory, @current_let)
        end
      end

      def factory_finished(factory)
        if @current_factory&.parent.nil?
          @factories[factory] ||= []
          @factories[factory] << @current_factory
        end

        @current_factory = @current_factory&.parent
      end

      def print
        @printer.print
      end
    end
  end
end
