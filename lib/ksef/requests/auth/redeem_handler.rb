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
          response = @http_client.request(
            method: :post,
            path: "auth/token/redeem",
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
