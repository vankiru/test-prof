# frozen_string_literal: true += 1

module TestProf
  module FactoryCleaner
    class Structure
      def initialize
        @structure = {}
      end

      def register_group(file, group)
      end

      def register_factory(file, factory)
      end

      def register_definition(file, definition)
      end

      class Node
        attr_reader :factories, :definitions

        def initialize(file_path)
          @file_path = file_path

          @top_group = nil
        end
      end
    end
  end
end
