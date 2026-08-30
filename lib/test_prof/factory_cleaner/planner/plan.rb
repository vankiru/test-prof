# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Plan
        attr_reader :patches, :ordered, :file_path
        attr_accessor :before_all_last_line

        def initialize(analyzer, file_path)
          @analyzer = analyzer
          @file_path = file_path
          @patches = {}
          @ordered = []
          @before_all = false
        end

        def shared_example?
          file_path.include?("spec/support/shared_")
        end

        def factories
          @analyzer.factories[file_path]
        end

        def depth_order
          @analyzer.factories[file_path].depth_order
        end

        def <<(patch)
          return duplicate(patch) if duplicate?(patch)

          patch.plan = self
          @patches[patch.object] = patch
          @ordered << patch

          patch
        end

        def each(&block)
          @ordered.each(&block)
        end

        def before_all?
          @before_all
        end

        def before_all!
          @before_all = true
          @before_all_last_line += 1
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
