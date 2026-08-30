# frozen_string_literal: true

require "test_prof/factory_cleaner/planner/plan"
require "test_prof/factory_cleaner/planner/patch"
require "test_prof/factory_cleaner/planner/printer"

module TestProf
  module FactoryCleaner
    class Planner
      FACTORIES = %i[
        organization
        billing_entity
        billable_metric
        plan
        customer
        invoice
      ].freeze

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
        variation.nil? || overrides.all? { |override| override.count < 2 }
      end

      def patch_factory?(factory)
        FACTORIES.include?(factory.name)
      end

      def build_explicit_factory_patch(factory, order = 0)
        patches = []

        factory.explicit_associations.each do |name, association|
          patches << build_explicit_factory_patch(association)
        end

        factory.implicit_associations.each do |name, association|
          patches << build_implicit_factory_patch(association, factory)
        end

        next unless patch_factory?(factory)

        factory.attributes.each do |name, attribute|
          patches << build_attribute_patch(attribute)
        end

        @current_plan << ExplicitFactoryPatch.new(factory, patches.compact, order:)
      end

      def build_implicit_factory_patch(factory, parent)
        suggestion = find_suggestion(factory, parent)

        patch = suggest_patch(factory, suggestion)
        return patch if patch

        patches = factory.implicit_associations.map do |name, association|
          build_implicit_factory_patch(association, parent)
        end

        if suggestion[:definition]
          patch = SuggestedDefinitionPatch.new(factory, patches.compact, definition: suggestion[:definition])
        else
          patch = ImplicitFactoryPatch.new(factory, patches.compact, group: suggestion[:group])
        end

        @current_plan << patch if patch_factory?(factory)
      end

      def build_attribute_patch(definition)
        patches = definition.attributes.map do |name, attribute|
          build_attribute_patch(attribute)
        end

        @current_plan << AttributePatch.new(definition, patches)
      end

      def find_suggestion(factory, parent)
        groups = parent.examples.map do |example|
          find_factory_definition_group(factory, example)
        end

        unique = groups.compact.uniq { |group| group[:group] }
        return unique.first if unique.one?
      end

      def find_factory_definition_group(factory, example)
        example.ancestors.reverse.find do |group|
          factories = group.factories.select do |suggestion|
            suggestion.top_level? && suggestion.name == factory.name 
          end

          definition = group.definitions.find do |suggestion|
            suggestion.name == factory.name 
          end

          if factories.any? || definitions.any?
            break {group:, factories:, definition:}
          end
        end
      end

      def suggest_patch(factory, suggestion)
        return unless suggestion[:factories].one?
        patch = @current_plan.patches[suggestion[:factories].first]
        patch.default!
      end
    end
  end
end
