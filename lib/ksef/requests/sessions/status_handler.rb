# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for checking session status
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(reference_number)
          response = @http_client.get("sessions/#{reference_number}")
          response.json
        end
      end
    end
  end
end
