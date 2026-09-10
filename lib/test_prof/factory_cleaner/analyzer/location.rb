# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Location
        attr_reader :file_path, :line_number, :original_line_number

        def initialize(file_path, line_number)
          @file_path = file_path
          @line_number = line_number.to_i
          @original_line_number = line_number.to_i
        end

        def shift(by)
          @line_number += by
        end

        def to_s
          string = "#{@file_path}:#{@line_number}"
          string += "(#{@original_line_number})" if shifted?

          string
        end

        def eql?(location)
          @file_path == location.file_path && @line_number == location.line_number
        end
        alias_method :==, :eql?

        def hash
          to_s.hash
        end

        private

        def shifted?
          @original_line_number != @line_number
        end
      end
    end
  end
end
