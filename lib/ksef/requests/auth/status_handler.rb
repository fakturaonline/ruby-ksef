# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for authentication status check
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(reference_number)
          response = @http_client.get("auth/#{reference_number}")
          response.json
        end
      end
    end
  end
end
