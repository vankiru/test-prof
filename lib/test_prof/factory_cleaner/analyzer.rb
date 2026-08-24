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

      def let_started(name, location)
        @level += 1

        params = {
          name:,
          location:,
        }

        if @current_let
          @current_let = @current_let.dependency(params)
        elsif location
          @current_let = Let.new(params)
        end
      end

      def let_finished(name)
        if @current_let
          @lets.delete(@level + 1)
          @lets[@level] ||= {}
          @lets[@level][name] = @current_let
        end

        @current_let = @current_let&.parent
        @level -= 1
      end

      def factory_started(factory, **options)
        @level += 1

        params = {
          name: factory,
          definition: @current_let,
          example: @current_example,
        }

        if @current_factory
          @current_factory = @current_factory.association(params)
        else
          @current_factory = Factory.new(params)
        end
      end

      def factory_finished(factory)
        @lets[@level]&.each do |name, let|
          @current_factory.option(name, let)
        end
        @lets.delete(@level)

        if @current_factory&.parent.nil?
          @factories[factory] ||= Set.new
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
