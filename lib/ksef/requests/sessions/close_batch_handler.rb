# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for closing batch session
      class CloseBatchHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(session_reference_number)
          response = @http_client.post(
            "sessions/batch/#{session_reference_number}/close"
          )
          response.json
        end
      end
    end
  end
end
