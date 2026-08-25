# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Factories
        def initialize(analyzer)
          @analyzer = analyzer
        end

        def factories
          return @factories if defined?(@factories)

          @factories = {}

          @analyzer.factories.each do |name, factories|
            @factories[name] = factories.reduce({}) do |hash, (variation, count)|
              next hash if variation.definition.nil?

              hash[variation.definition] ||= {}
              hash[variation.definition][variation] = count

              hash
            end
          end

          @factories
        end

        def order
          @analyzer.factories.values.map(&:keys).map(&:first).sort_by(&:depth).map(&:name)
        end
      end
    end
  end
end
