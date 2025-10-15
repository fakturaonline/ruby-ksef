# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for checking invoice export status
      class ExportsStatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get status of an invoice export by operation reference number
        # @param operation_reference_number [String] Export operation reference number
        # @return [Hash] Export status information
        def call(operation_reference_number)
          response = @http_client.get("invoices/exports/#{operation_reference_number}")
          response.json
        end
      end
    end
  end
end
