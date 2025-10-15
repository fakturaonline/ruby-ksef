# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for minimum string length
        class MinRule < AbstractRule
          # @param min [Integer] Minimum required length
          def initialize(min)
            @min = min
          end

          # Validate minimum length
          # @param value [String] String to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If string is below minimum length
          def call(value, attribute: nil)
            return unless value.to_s.length < @min

            raise ArgumentError, format_message(
              "String length #{value.to_s.length} is below minimum of #{@min}.",
              attribute
            )
          end
        end
      end
    end
  end
end
