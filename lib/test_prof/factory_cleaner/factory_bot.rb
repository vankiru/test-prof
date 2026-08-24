# frozen_string_literal: true

require "test_prof/factory_bot"
require "test_prof/ext/factory_bot_strategy"

module TestProf
  module FactoryCleaner
    class FactoryBotBuilder
      # implementation of #patch and #track methods
      # to provide unified interface for all factory-building gems
      using TestProf::FactoryBotStrategy

      # Monkey-patch FactoryBot
      def self.patch!
        TestProf::FactoryBot::FactoryRunner.prepend(FactoryBotPatch) if
          defined? TestProf::FactoryBot
      end

      def self.track(strategy, factory, **options)
        return yield unless strategy.create?

        FactoryCleaner.analyzer.factory_started(factory, **options)

        begin
          yield
        ensure
          FactoryCleaner.analyzer.factory_finished(factory)
        end
      end
    end

    # Wrap #run method with FactoryProf tracking
    module FactoryBotPatch
      def run(strategy = @strategy)
        FactoryBotBuilder.track(strategy, @name, traits: @trats, overrides: @overrides) { super }
      end
    end
  end
end

TestProf.activate("FCLEAN") do
  TestProf::FactoryCleaner::FactoryBotBuilder.patch!
end
