# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for checking invoice export status
      class ExportsStatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get status of an invoice export by reference number
        # Note: operationReferenceNumber was renamed to referenceNumber in RC5.3
        # @param reference_number [String] Export reference number
        # @return [Hash] Export status information
        def call(reference_number)
          response = @http_client.get("invoices/exports/#{reference_number}")
          response.json
        end
      end
    end
  end
end
