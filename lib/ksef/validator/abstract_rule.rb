# frozen_string_literal: true

module KSEF
  module Validator
    # Abstract base class for validation rules
    class AbstractRule
      # Handle validation for a value
      # @param value [Object] Value to validate
      # @param attribute [String, nil] Optional attribute name for error messages
      # @return [void]
      # @raise [ArgumentError] If validation fails
      def call(value, attribute: nil)
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      protected

      # Format error message with optional attribute name
      # @param message [String] Error message
      # @param attribute [String, nil] Optional attribute name
      # @return [String] Formatted error message
      def format_message(message, attribute = nil)
        return message unless attribute

        # Replace trailing period with attribute info
        if message.end_with?('.')
          message.sub(/\.$/, " for attribute #{attribute}.")
        else
          "#{message} for attribute #{attribute}"
        end
      end
    end
  end
end
