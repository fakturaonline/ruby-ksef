# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for checking invoice status
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(ksef_number)
          response = @http_client.get("invoices/#{ksef_number}/status")
          response.json
        end
      end
    end
  end
end
