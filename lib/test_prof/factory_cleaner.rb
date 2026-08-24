# frozen_string_literal: true

require "test_prof/factory_cleaner/analyzer"
require "test_prof/factory_cleaner/rspec"
require "test_prof/factory_cleaner/factory_bot"

module TestProf
  module FactoryCleaner
    class Configuration
    end

    class << self
      include TestProf::Logging

      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end

      def analyzer
        @analyzer ||= Analyzer.new
      end
    end
  end
end
