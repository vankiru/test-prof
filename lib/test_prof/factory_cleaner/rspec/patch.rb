# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class RSpecBuilder
      # Monkey-patch FactoryBot
      def self.patch!
        RSpec::Core::MemoizedHelpers::ThreadsafeMemoized.prepend(RSpecPatch)
        RSpec::Core::MemoizedHelpers::NonThreadSafeMemoized.prepend(RSpecPatch)
      end
    end

    module RSpecPatch
      def fetch_or_store(key)
        FactoryCleaner.analyzer.let_started(key)

        begin
          super
        ensure
          FactoryCleaner.analyzer.let_finished(key)
        end
      end
    end
  end
end
