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
        add_on
        membership
        plan
        customer
      ].freeze
        #invoice
        #subscription

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
        @current_top_group = @analyzer.groups[file_path]

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
        true
        #FACTORIES.include?(factory.name)
      end

      def build_explicit_factory_patch(factory, order = 0)
        patches = []

        factory.explicit_associations.each do |name, association|
          patches << build_explicit_factory_patch(association)
        end

        factory.implicit_associations.each do |name, association|
          patches << build_implicit_factory_patch(association, factory)
        end

        return unless patch_factory?(factory)

        factory.attributes.each do |name, attribute|
          patches << build_attribute_patch(attribute, factory)
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

        if suggestion
          if suggestion[:definition]
            patch = SuggestedDefinitionPatch.new(factory, patches.compact, definition: suggestion[:definition])
          else
            patch = ImplicitFactoryPatch.new(factory, patches.compact, group: suggestion[:group])
          end
        else
          patch = ImplicitFactoryPatch.new(factory, patches.compact, group: @current_top_group)
        end

        @current_plan << patch if patch_factory?(factory)
      end

      def build_attribute_patch(definition, parent)
        patches = definition.attributes.map do |name, attribute|
          build_attribute_patch(attribute, parent)
        end

        suggestion = find_suggestion(definition, parent)
        patch = suggest_attribute_patch(definition, suggestion)
        return patch if patch

        @current_plan << AttributePatch.new(definition, patches)
      end

      def find_suggestion(factory, parent)
        groups = parent.examples.map do |example|
          find_factory_definition_group(factory, example)
        end

        unique = groups.compact.uniq { |group| group[:factories] }
        return unique.first if unique.one?
      end

      def find_factory_definition_group(factory, example)
        example.ancestors.reverse.find do |group|
          factories = group.factories.select do |suggestion|
            suggestion.top_level? && suggestion.name == factory.name 
          end.uniq

          definition = group.definitions.find do |suggestion|
            suggestion.name == factory.name 
          end

          if factories.any? || definition
            break {group:, factories:, definition:}
          end
        end
      end

      def suggest_patch(factory, suggestion)
        return if suggestion.nil?
        return unless suggestion[:factories].one?

        patch = @current_plan.patches[suggestion[:factories].first]
        patch&.default!
        patch
      end

      def suggest_attribute_patch(factory, suggestion)
        return if suggestion.nil?
        return if !suggestion[:factories].one? && suggestion[:definition].nil?

        patch = @current_plan.patches[suggestion[:factories].first]
        patch ||= @current_plan.patches.find do |patch, _|
          patch.name == suggestion[:definition].name
        end.last

        patch&.default!
        patch
      end
    end
  end
end
