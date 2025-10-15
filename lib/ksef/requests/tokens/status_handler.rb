# frozen_string_literal: true

module KSEF
  module Requests
    module Tokens
      # Handler for checking token status
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get status of a token by reference number
        # @param reference_number [String] Token reference number
        # @return [Hash] Token status information
        def call(reference_number)
          response = @http_client.get("tokens/#{reference_number}")
          response.json
        end
      end
    end
  end
end
