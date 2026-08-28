# frozen_string_literal: true

require "test_prof/factory_cleaner/planner/plan"
require "test_prof/factory_cleaner/planner/patch"
require "test_prof/factory_cleaner/planner/printer"

module TestProf
  module FactoryCleaner
    class Planner
      attr_reader :plans

      def initialize(analyzer)
        @analyzer = analyzer
        @printer = Printer.new(self)
      end

      def run
        @plans = {}

        @analyzer.factories.each do |file_path, factories|
          @plans[file_path] = build_plan(file_path, factories)
        end

        @plans
      end

      def print
        @printer.print
      end

      private

      def build_plan(file_path, factories)
        @current_plan = Plan.new(@analyzer, file_path)

        factories.depth_order.each do |name|
          factories.top_level[name].each do |variation, overrides|
            next if skip?(variation, overrides)

            overrides.each_with_index.reverse_each do |override, order|
              next if override.shared_example?
              build_explicit_factory_patch(override, order)
            end
          end
        end

        @current_plan
      end

      def skip?(variation, overrides)
        variation.nil? || overrides.all? { |override| override.count == 1 }
      end

      FACTORIES = %i[
        organization
        billing_entity
        billable_metric
        plan
        customer
        subscription
      ].freeze

      def skip_factory?(factory)
        !FACTORIES.include?(factory.name)
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

        unless skip_factory?(factory)
          @current_plan << ExplicitFactoryPatch.new(factory, patches.compact, order:)
        end
      end

      def build_implicit_factory_patch(factory, parent)
        suggestion = suggest_patch(factory, parent)
        return suggestion if suggestion

        patches = factory.implicit_associations.map do |name, association|
          build_implicit_factory_patch(association, parent)
        end

        unless skip_factory?(factory)
          @current_plan << ImplicitFactoryPatch.new(factory, patches.compact)
        end
      end

      def build_attribute_patch(definition)
        patches = definition.attributes.map do |name, attribute|
          build_attribute_patch(attribute)
        end

        @current_plan << AttributePatch.new(definition, patches)
      end

      def suggest_patch(factory, parent)
        suggestion = suggest_factory(factory, parent)
        patch = @current_plan.patches[suggestion]

        @current_plan << patch if patch
      end

      def suggest_factory(factory, parent)
        @current_plan.factories.find do |suggestion|
          next false unless suggestion.top_level?
          next false unless suggestion.name == factory.name 

          groups = parent.examples.map do |example|
            defined_in_group(suggestion, example)
          end

          groups.compact.uniq.size == 1
        end
      end

      def defined_in_group(factory, example)
        example.ancestors.reverse.find do |group|
          factory.definition&.defined_in?(group)
        end
      end
    end
  end
end
