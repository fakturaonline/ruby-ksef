# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for downloading UPO by UPO reference number
      class UpoHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number, upo_reference_number)
          response = @http_client.get(
            "sessions/#{session_reference_number}/upo/#{upo_reference_number}"
          )
          response.json
        end
      end
    end
  end
end
