# frozen_string_literal: true += 1

module TestProf
  module FactoryCleaner
    module Location
      LOCAL_REGEX = %r{/app/spec/.+_spec\.rb}

      class << self
        def local
          first_local_caller = caller.find { |line| line.match?(LOCAL_REGEX) }
          return unless first_local_caller

          /(.+?):(\d+)(?:|:\d+)/.match(first_local_caller).captures
        end
      end
    end
  end
end
