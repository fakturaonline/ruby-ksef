# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Array
        # Validation rule for maximum array size
        class MaxRule < AbstractRule
          # @param max [Integer] Maximum allowed array size
          def initialize(max)
            @max = max
          end

          # Validate maximum array size
          # @param value [Array] Array to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If array exceeds maximum size
          def call(value, attribute: nil)
            unless value.is_a?(::Array)
              raise ArgumentError, format_message(
                "Value must be an array.",
                attribute
              )
            end

            return unless value.size > @max

            raise ArgumentError, format_message(
              "Array size #{value.size} exceeds maximum of #{@max}.",
              attribute
            )
          end
        end
      end
    end
  end
end
