# frozen_string_literal: true

require "test_prof/factory_cleaner/planner/factories"
require "test_prof/factory_cleaner/planner/plan"
require "test_prof/factory_cleaner/planner/patch"
require "test_prof/factory_cleaner/planner/printer"

module TestProf
  module FactoryCleaner
    class Planner
      def initialize(analyzer)
        @analyzer = analyzer
        @plan = Plan.new
        @factories = Factories.new(analyzer)
        @printer = Printer.new(self)
      end

      def plan
        depth_order.each do |name|
          factories[name].each do |definition, overrides|
            overrides.each_with_index do |(override, count), order|
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
        @factories.order
      end

      def factories
        @factories.factories
      end

      private

      def build_explicit_factory_patch(factory, order = 0)
        patches = []

        factory.explicit_associations.each do |name, association|
          patches << build_explicit_factory_patch(association)
        end

        factory.implicit_associations.each do |name, association|
          patches << build_implicit_factory_patch(association)
        end

        factory.attributes.each do |name, attribute|
          patches << build_attribute_patch(attribute)
        end

        @plan << ExplicitFactoryPatch.new(factory, patches, order:)
      end

      def build_implicit_factory_patch(factory)
        patches = factory.implicit_associations.map do |name, association|
          build_implicit_factory_patch(association)
        end

        @plan << ImplicitFactoryPatch.new(factory, patches, suggestion: suggest_patch(factory))
      end

      def build_attribute_patch(definition)
        patches = definition.attributes.map do |name, attribute|
          build_attribute_patch(attribute)
        end

        @plan << AttributePatch.new(definition, patches)
      end

      def suggest_patch(factory)
      end
    end
  end
end
