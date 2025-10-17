# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for authentication challenge request
      class ChallengeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.request(
            method: :post,
            path: "auth/challenge",
            body: {},
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
