# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for session revocation
      class RevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.delete("auth/token")
          response.json
        end
      end
    end
  end
end
