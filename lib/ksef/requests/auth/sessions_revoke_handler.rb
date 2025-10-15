# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for revoking a specific session
      class SessionsRevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke a specific session by reference number
        # @param reference_number [String] Session reference number
        # @return [Hash] Revocation response
        def call(reference_number)
          response = @http_client.delete("auth/sessions/#{reference_number}")
          response.json
        end
      end
    end
  end
end
