# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Number
        # Validation rule for decimal numbers
        class DecimalRule < AbstractRule
          # @param max_digits [Integer] Maximum total digits
          # @param max_decimals [Integer] Maximum decimal places
          def initialize(max_digits:, max_decimals:)
            @max_digits = max_digits
            @max_decimals = max_decimals
          end

          # Validate decimal number
          # @param value [Numeric, String] Number to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If number is invalid
          def call(value, attribute: nil)
            value_str = value.to_s.gsub(/[,\s]/, '')

            unless value_str.match?(/^-?\d+(\.\d+)?$/)
              raise ArgumentError, format_message(
                "Value must be a valid decimal number.",
                attribute
              )
            end

            parts = value_str.split('.')
            integer_part = parts[0].gsub('-', '')
            decimal_part = parts[1] || ''

            total_digits = integer_part.length + decimal_part.length

            if total_digits > @max_digits
              raise ArgumentError, format_message(
                "Number has too many digits. Maximum is #{@max_digits}.",
                attribute
              )
            end

            if decimal_part.length > @max_decimals
              raise ArgumentError, format_message(
                "Number has too many decimal places. Maximum is #{@max_decimals}.",
                attribute
              )
            end
          end
        end
      end
    end
  end
end
