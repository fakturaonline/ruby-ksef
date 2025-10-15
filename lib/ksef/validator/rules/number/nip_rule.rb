# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Number
        # Validation rule for Polish NIP numbers
        class NipRule < AbstractRule
          WEIGHTS = [6, 5, 7, 2, 3, 4, 5, 6, 7].freeze

          # Validate NIP number
          # @param value [String] NIP number to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If NIP is invalid
          def call(value, attribute: nil)
            value_str = value.to_s

            unless value_str.match?(/^\d{10}$/)
              raise ArgumentError, format_message(
                "Invalid NIP number format. It should be 10 digits.",
                attribute
              )
            end

            digits = value_str.chars.map(&:to_i)
            sum = 0

            9.times do |i|
              sum += digits[i] * WEIGHTS[i]
            end

            checksum = sum % 11

            return unless checksum == 10 || digits[9] != checksum

            raise ArgumentError, format_message(
              "Invalid NIP number checksum.",
              attribute
            )
          end
        end
      end
    end
  end
end
