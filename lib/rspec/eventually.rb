require 'rspec/eventually/version'
require 'rspec/core'

module Rspec
  module Eventually
    class << self
      attr_accessor :timeout, :pause
    end
    self.timeout = 5
    self.pause = 0.1

    class FailedMatcherError < StandardError; end

    class Eventually
      def by_suppressing_errors
        tap { @suppress_errors = true }
      end

      def initialize(target, custom_msg = nil)
        @target = target
        @tries = 0
        @negative = false
        @custom_msg = custom_msg
        @pause = pause
      end

      def matches?(expected_block)
        Timeout.timeout(timeout) { eventually_matches? expected_block }
      rescue Timeout::Error
        @tries == 0 && raise('Timeout before first evaluation, use a longer `eventually` timeout \
          or shorter `eventually` pause')
      end

      def does_not_match?
        fail 'Use eventually_not instead of expect(...).to_not'
      end

      def failure_message
        msg = @custom_msg || @target.failure_message
        "After #{@tries} tries, the last failure message was:\n#{msg}"
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

      def pause_for(pause)
        tap { @pause = pause }
      end

      private

      def eventually_matches?(expected_block)
        target_matches?(expected_block) || fail(FailedMatcherError)
      rescue => e
        if suppress_errors || e.is_a?(FailedMatcherError)
          sleep pause
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

      def pause
        @pause || Rspec::Eventually.pause
      end
    end

    def eventually(target, custom_msg = nil)
      Eventually.new(target, custom_msg)
    end

    def eventually_not(target, custom_msg = nil)
      Eventually.new(target, custom_msg).not
    end

    RSpec.configure do |config|
      config.include ::Rspec::Eventually
    end
  end
end
