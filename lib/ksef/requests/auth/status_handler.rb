# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for authentication status check
      class StatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(reference_number)
          response = @http_client.request(
            method: :get,
            path: "auth/#{reference_number}",
            headers: {
              "Accept" => "application/json",
              "Content-Type" => "application/json"
            }
          )
          response.json
        end
      end
    end
  end
end
