# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for token redemption after successful authentication
      class RedeemHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.post("auth/token/redeem")
          response.json
        end
      end
    end
  end
end
