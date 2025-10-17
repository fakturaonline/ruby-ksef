# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for checking invoice status
      # NOTE: In KSeF API v2, there is no dedicated status endpoint.
      # Status information is retrieved through:
      # - GET /sessions/{referenceNumber}/invoices/{invoiceReferenceNumber}
      # - GET /invoices/ksef/{ksefNumber} (full invoice with metadata)
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get invoice metadata which includes status information
        def call(ksef_number)
          response = @http_client.get("invoices/ksef/#{ksef_number}")
          # Returns full invoice XML, not just status
          # For status only, use sessions endpoint with invoice reference
          response.json
        end
      end
    end
  end
end
