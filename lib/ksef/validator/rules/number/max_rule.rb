# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Number
        # Validation rule for maximum number value
        class MaxRule < AbstractRule
          # @param max [Numeric] Maximum allowed value
          def initialize(max)
            @max = max
          end

          # Validate maximum value
          # @param value [Numeric] Number to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If value exceeds maximum
          def call(value, attribute: nil)
            numeric_value = value.is_a?(Numeric) ? value : value.to_f

            return unless numeric_value > @max

            raise ArgumentError, format_message(
              "Value #{numeric_value} exceeds maximum of #{@max}.",
              attribute
            )
          end
        end
      end
    end
  end
end
