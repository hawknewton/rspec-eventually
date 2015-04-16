require 'rspec/eventually/version'
require 'rspec'

module Rspec
  module Eventually
    class << self
      attr_accessor :timeout
    end
    self.timeout = 5

    class FailedMatcherError < StandardError; end

    class Eventually
      def by_suppressing_errors
        tap { @suppress_errors = true }
      end

      def initialize(target)
        @target = target
        @tries = 0
        @negative = false
      end

      def matches?(expected_block)
        Timeout.timeout(timeout) { eventually_matches? expected_block }
      rescue Timeout::Error
        @tries == 0 && raise('Timeout before first evaluation, use a longer `eventually` timeout')
      end

      def does_not_match?
        fail 'Use eventually_not instead of expect(...).to_not'
      end

      def failure_message
        "After #{@tries} tries, the last failure message was:\n#{@target.failure_message}"
      end

      def not
        tap { @negative = true }
      end

      def supports_block_expectations?
        true
      end

      def suppress_errors
        @suppress_errors || false
      end

      def within(timeout)
        tap { @timeout = timeout }
      end

      private

      def eventually_matches?(expected_block)
        target_matches?(expected_block) || fail(FailedMatcherError)
      rescue => e
        if suppress_errors || e.is_a?(FailedMatcherError)
          sleep 0.1
          @tries += 1
          retry
        else
          raise
        end
      end

      def target_matches?(expected_block)
        result = @target.matches? expected_block.call
        @negative ? !result : result
      end

      def timeout
        @timeout || Rspec::Eventually.timeout
      end
    end

    def eventually(target)
      Eventually.new target
    end

    def eventually_not(target)
      Eventually.new(target).not
    end

    RSpec.configure do |config|
      config.include ::Rspec::Eventually
    end
  end
end
