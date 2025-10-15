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
          response = @http_client.get("auth/challenge")
          response.json
        end
      end
    end
  end
end
