# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for getting invoice details in session
      class InvoiceHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, invoice_reference_number)
          response = @http_client.get(
            "sessions/#{session_reference_number}/invoices/#{invoice_reference_number}"
          )
          response.json
        end
      end
    end
  end
end
