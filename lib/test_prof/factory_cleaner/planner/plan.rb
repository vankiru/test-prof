# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Plan
        attr_reader :patches, :ordered

        def initialize
          @patches = {}
          @ordered = []
        end

        def <<(patch)
          return duplicate(patch) if duplicate?(patch)

          @patches[patch.object] = patch
          @ordered << patch

          patch
        end

        def each(&block)
          @ordered.each(&block)
        end

        private

        def duplicate(patch)
          @patches[patch.object]
        end

        def duplicate?(patch)
          @patches.has_key?(patch.object)
        end
      end
    end
  end
end
