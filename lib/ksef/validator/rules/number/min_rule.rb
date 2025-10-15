# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Number
        # Validation rule for minimum number value
        class MinRule < AbstractRule
          # @param min [Numeric] Minimum allowed value
          def initialize(min)
            @min = min
          end

          # Validate minimum value
          # @param value [Numeric] Number to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If value is below minimum
          def call(value, attribute: nil)
            numeric_value = value.is_a?(Numeric) ? value : value.to_f

            if numeric_value < @min
              raise ArgumentError, format_message(
                "Value #{numeric_value} is below minimum of #{@min}.",
                attribute
              )
            end
          end
        end
      end
    end
  end
end
