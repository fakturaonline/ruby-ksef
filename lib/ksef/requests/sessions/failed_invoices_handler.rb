# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for listing failed invoices in session
      class FailedInvoicesHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, params = {})
          response = @http_client.get(
            "sessions/#{session_reference_number}/invoices/failed",
            params: params
          )
          response.json
        end
      end
    end
  end
end
