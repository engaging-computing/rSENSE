module Minitest
  module Reporters
    class SeedReporter < BaseReporter
      def initialize(options = {})
        super
        @options = options
      end

      def start
        super
        puts "Initializing RNG with seed #{@options[:seed]}"
        puts ''
      end

      def before_test(test)
        super
      end

      def before_suite(suite)
        super
      end

      def after_suite(suite)
        super
      end

      def record(test)
        super
      end

      def report
        super
      end
    end
  end
end
