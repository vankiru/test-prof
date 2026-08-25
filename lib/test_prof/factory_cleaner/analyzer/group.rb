# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Group
        attr_reader :parent

        def initialize(group, parent, level)
          @name = group&.fetch(:name)
          @file_path, @line_number = group&.fetch(:location)
          @parent = parent
          @level = level
        end

        def location
          "#{@file_path}:#{@line_number}"
        end

        def inspect
          "group (#{name}, #{level})"
        end
      end
    end
  end
end
