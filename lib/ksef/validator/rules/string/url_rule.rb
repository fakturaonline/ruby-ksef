# frozen_string_literal: true

require "uri"

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for URLs
        class UrlRule < AbstractRule
          # Validate URL format
          # @param value [String] URL to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If URL is invalid
          def call(value, attribute: nil)
            uri = URI.parse(value.to_s)

            unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
              raise ArgumentError, format_message(
                "Invalid URL format.",
                attribute
              )
            end
          rescue URI::InvalidURIError
            raise ArgumentError, format_message(
              "Invalid URL format.",
              attribute
            )
          end
        end
      end
    end
  end
end
