# frozen_string_literal: true

require "test_prof/factory_cleaner/rspec/listener"
require "test_prof/factory_cleaner/rspec/patch"

TestProf.activate("FCLEAN") do
  TestProf::FactoryCleaner::RSpecBuilder.patch!

  RSpec.configure do |config|
    listener = nil

    config.before(:suite) do
      listener = TestProf::FactoryCleaner::RSpecListener.new

      config.reporter.register_listener(
        listener, *TestProf::FactoryCleaner::RSpecListener::NOTIFICATIONS
      )
    end

    config.after(:suite) { listener&.report }
  end
end
