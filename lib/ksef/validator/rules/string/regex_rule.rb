# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for regex pattern matching
        class RegexRule < AbstractRule
          # @param pattern [Regexp, String] Regex pattern to match
          # @param message [String, nil] Optional custom error message
          def initialize(pattern, message: nil)
            @pattern = pattern.is_a?(Regexp) ? pattern : Regexp.new(pattern)
            @custom_message = message
          end

          # Validate against regex pattern
          # @param value [String] Value to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If value doesn't match pattern
          def call(value, attribute: nil)
            unless value.to_s.match?(@pattern)
              message = @custom_message || "Value does not match required pattern."
              raise ArgumentError, format_message(message, attribute)
            end
          end
        end
      end
    end
  end
end
