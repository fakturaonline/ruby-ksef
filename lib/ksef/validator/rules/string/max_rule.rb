# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for maximum string length
        class MaxRule < AbstractRule
          # @param max [Integer] Maximum allowed length
          def initialize(max)
            @max = max
          end

          # Validate maximum length
          # @param value [String] String to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If string exceeds maximum length
          def call(value, attribute: nil)
            return unless value.to_s.length > @max

            raise ArgumentError, format_message(
              "String length #{value.to_s.length} exceeds maximum of #{@max}.",
              attribute
            )
          end
        end
      end
    end
  end
end
