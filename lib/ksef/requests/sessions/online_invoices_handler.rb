# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for listing invoices in session
      # NOTE: This handler is DEPRECATED and redundant.
      # Use InvoicesHandler instead which works for all session types (online/batch).
      #
      # The endpoint /sessions/online/{ref}/invoices does NOT support GET method,
      # only POST for sending invoices. Use /sessions/{ref}/invoices for listing.
      class OnlineInvoicesHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, params = {})
          # Correct endpoint: sessions/{ref}/invoices works for all session types
          response = @http_client.get(
            "sessions/#{session_reference_number}/invoices",
            params: params
          )
          response.json
        end
      end
    end
  end
end
