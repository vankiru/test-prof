# frozen_string_literal: true
module TestProf
  module FactoryCleaner
    class RSpecListener
      NOTIFICATIONS = %i[
        example_started
        example_finished
        example_group_started
        example_group_finished
      ].freeze

      attr_reader :analyzer, :planner, :executor

      def initialize
        @analyzer = FactoryCleaner.analyzer
        @planner = Planner.new(analyzer)
        @executor = Executor.new(planner, analyzer)

        @current_group = nil
        @current_example = nil

        @analyzer.start
      end

      def example_started(notification)
        analyzer.example_started(example(notification))
      end

      def example_finished(notification)
        analyzer.example_finished(example(notification))
      end

      def example_group_started(notification)
        analyzer.group_started(group(notification))
      end

      def example_group_finished(notification)
        analyzer.group_finished(group(notification))
      end

      def report
        #analyzer.print
        puts
        planner.run
        #planner.print
        puts
        executor.run
      end

      private

      def group(notification)
        {
          name: notification.group.description,
          location: notification.group.metadata[:location]
        }
      end

      def example(notification)
        {
          name: notification.example.description,
          location: notification.example.metadata[:location]
        }
      end
    end
  end
end
