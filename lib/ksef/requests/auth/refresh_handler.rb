# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for access token refresh
      class RefreshHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.post("auth/token/refresh")
          response.json
        end
      end
    end
  end
end
