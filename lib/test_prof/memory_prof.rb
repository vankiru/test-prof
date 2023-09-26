# frozen_string_literal: true

require "test_prof/memory_prof/tracker"

module TestProf
  # MemoryProf can help in detecting test examples causing memory spikes.
  # It supports two metrics: RSS and allocations.
  #
  # Example:
  #
  #   TEST_MEM_PROF='rss' rspec ...
  #   TEST_MEM_PROF='alloc' rspec ...
  #
  # By default MemoryProf shows the top 5 examples and groups (for RSpec) but you can
  # set how many items to display with `TEST_MEM_PROF_COUNT`:
  #
  #   TEST_MEM_PROF='rss' TEST_MEM_PROF_COUNT=10 rspec ...
  #
  # The examples block shows the amount of memory used by each example, and the groups
  # block displays the memory allocated by other code defined in the groups. For example,
  # RSpec groups may include heavy `before(:all)` (or `before_all`) setup blocks, so it is
  # helpful to see which groups use the most amount of memory outside of their examples.

  module MemoryProf
    # MemoryProf configuration
    class Configuration
      attr_reader :mode, :top_count

      def initialize
        self.mode = ENV["TEST_MEM_PROF"]
        self.top_count = ENV["TEST_MEM_PROF_COUNT"]
      end

      def mode=(value)
        @mode = (value == "alloc") ? :alloc : :rss
      end

      def top_count=(value)
        @top_count = (value || 5).to_i
      end
    end

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end

      def tracker
        case config.mode
        when :alloc
          AllocTracker.new(config.top_count)
        when :rss
          RssTracker.new(config.top_count)
        end
      end
    end
  end
end

require "test_prof/memory_prof/rspec" if TestProf.rspec?
require "test_prof/memory_prof/minitest" if TestProf.minitest?
