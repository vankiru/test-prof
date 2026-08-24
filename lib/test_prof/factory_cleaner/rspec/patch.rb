# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class RSpecBuilder
      # Monkey-patch FactoryBot
      def self.patch!
        RSpec::Core::ExampleGroup.singleton_class.prepend(RSpecPatch)
      end
    end

    module RSpecPatch
      def let(name, &block)
        # We have to pass the block directly to `define_method` to
        # allow it to use method constructs like `super` and `return`.
        raise "#let or #subject called without a block" if block.nil?

        # A list of reserved words that can't be used as a name for a memoized helper
        # Matches for both symbols and passed strings
        if [:initialize, :to_s].include?(name.to_sym)
          raise ArgumentError, "#let or #subject called with reserved name `#{name}`"
        end

        our_module = RSpec::Core::MemoizedHelpers.module_for(self)

        # If we have a module clash in our helper module
        # then we need to remove it to prevent a warning.
        #
        # Note we do not check ancestor modules (see: `instance_methods(false)`)
        # as we can override them.
        if our_module.method_defined?(name, false)
          our_module.__send__(:remove_method, name)
        end
        our_module.__send__(:define_method, name, &block)

        # If we have a module clash in the example module
        # then we need to remove it to prevent a warning.
        #
        # Note we do not check ancestor modules (see: `instance_methods(false)`)
        # as we can override them.
        if method_defined?(name, false)
          remove_method(name)
        end

        # Apply the memoization. The method has been defined in an ancestor
        # module so we can use `super` here to get the value.
        location = parse_location
        if block.arity == 1
          define_method(name) do
            FactoryCleaner.analyzer.let_started(name, location)
            begin
              __memoized.fetch_or_store(name) { super(RSpec.current_example, &nil) }
            ensure
              FactoryCleaner.analyzer.let_finished(name)
            end
          end
        else
          define_method(name) do
            FactoryCleaner.analyzer.let_started(name, location)
            begin
              __memoized.fetch_or_store(name) { super(&nil) }
            ensure
              FactoryCleaner.analyzer.let_finished(name)
            end
          end
        end
      end

      private

      LOCAL_REGEX = %r{/app/spec/.+_spec\.rb}

      def parse_location
        first_local_caller = caller.find { |line| line.match?(LOCAL_REGEX) }
        return unless first_local_caller

        file_path, line_number = /(.+?):(\d+)(?:|:\d+)/.match(first_local_caller).captures
      end
    end
  end
end
