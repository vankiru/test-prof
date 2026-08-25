# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Example
        attr_reader :group

        def initialize(example, group, level)
          @name = example&.fetch(:name)
          @file_path, @line_number = example&.fetch(:location)
          @group = group
          @level = level
        end

        def location
          "#{@file_path}:#{@line_number}"
        end

        def inspect
          "example (#{name}, #{level})"
        end
      end
    end
  end
end
