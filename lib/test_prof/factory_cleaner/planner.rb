# frozen_string_literal: true

require "test_prof/factory_cleaner/planner/plan"
require "test_prof/factory_cleaner/planner/patch"
require "test_prof/factory_cleaner/planner/printer"

module TestProf
  module FactoryCleaner
    class Planner
      attr_reader :plan

      def initialize(analyzer)
        @analyzer = analyzer
        @plan = Plan.new
        @printer = Printer.new(self)
      end

      def run
        depth_order.each do |name|
          factories[name].each do |variation, overrides|
            next if skip?(variation, overrides)

            overrides.each_with_index.reverse_each do |override, order|
              build_explicit_factory_patch(override, order)
            end
          end
        end

        @plan
      end

      def print
        @printer.print
      end

      def depth_order
        @analyzer.factories.depth_order
      end

      def factories
        @analyzer.factories.top_level
      end

      private

      def skip?(variation, overrides)
        variation.nil? || overrides.all? { |override| override.count == 1 }
      end

      def build_explicit_factory_patch(factory, order = 0)
        patches = []

        factory.explicit_associations.each do |name, association|
          patches << build_explicit_factory_patch(association)
        end

        factory.implicit_associations.each do |name, association|
          patches << build_implicit_factory_patch(association, factory)
        end

        factory.attributes.each do |name, attribute|
          patches << build_attribute_patch(attribute)
        end

        @plan << ExplicitFactoryPatch.new(factory, patches.compact, order:)
      end

      def build_implicit_factory_patch(factory, parent)
        return if suggest_patch(factory, parent)

        patches = factory.implicit_associations.map do |name, association|
          build_implicit_factory_patch(association, parent)
        end

        @plan << ImplicitFactoryPatch.new(factory, patches.compact)
      end

      def build_attribute_patch(definition)
        patches = definition.attributes.map do |name, attribute|
          build_attribute_patch(attribute)
        end

        @plan << AttributePatch.new(definition, patches)
      end

      def suggest_patch(factory, parent)
        suggestion = suggest_factory(factory, parent)
        patch = @plan.patches[suggestion]

        @plan << patch if patch
      end

      def suggest_factory(factory, parent)
        @analyzer.factories.find do |suggestion|
          next false unless suggestion.top_level?
          next false unless suggestion.name == factory.name 

          groups = parent.examples.map do |example|
            defined_in_group(parent, example)
          end

          groups.uniq.size == 1
        end
      end

      def defined_in_group(factory, example)
        example.ancestors.reverse.find do |group|
          factory.definition.defined_in?(group)
        end
      end
    end
  end
end
