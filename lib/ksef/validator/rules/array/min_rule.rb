# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Array
        # Validation rule for minimum array size
        class MinRule < AbstractRule
          # @param min [Integer] Minimum required array size
          def initialize(min)
            @min = min
          end

          # Validate minimum array size
          # @param value [Array] Array to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If array is below minimum size
          def call(value, attribute: nil)
            unless value.is_a?(::Array)
              raise ArgumentError, format_message(
                "Value must be an array.",
                attribute
              )
            end

            return unless value.size < @min

            raise ArgumentError, format_message(
              "Array size #{value.size} is below minimum of #{@min}.",
              attribute
            )
          end
        end
      end
    end
  end
end
