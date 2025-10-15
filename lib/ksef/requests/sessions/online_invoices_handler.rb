# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for listing invoices in online session
      class OnlineInvoicesHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, params = {})
          response = @http_client.get(
            "sessions/online/#{session_reference_number}/invoices",
            params: params
          )
          response.json
        end
      end
    end
  end
end
