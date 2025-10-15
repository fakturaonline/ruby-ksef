# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for revoking the current session
      class SessionsRevokeCurrentHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke the current session
        # @return [Hash] Revocation response
        def call
          response = @http_client.delete("auth/sessions/current")
          response.json
        end
      end
    end
  end
end
