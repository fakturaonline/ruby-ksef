# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for email addresses
        class EmailRule < AbstractRule
          EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

          # Validate email format
          # @param value [String] Email to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If email is invalid
          def call(value, attribute: nil)
            return if value.to_s.match?(EMAIL_REGEX)

            raise ArgumentError, format_message(
              "Invalid email format.",
              attribute
            )
          end
        end
      end
    end
  end
end
