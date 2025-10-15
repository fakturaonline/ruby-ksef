# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for downloading UPO by KSEF number
      class UpoByKsefNumberHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, ksef_number)
          response = @http_client.get(
            "sessions/#{session_reference_number}/invoices/ksef/#{ksef_number}/upo"
          )
          response.json
        end
      end
    end
  end
end
