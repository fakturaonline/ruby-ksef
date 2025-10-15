# frozen_string_literal: true

module KSEF
  module Requests
    module Tokens
      # Handler for revoking token
      class RevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(token_number)
          response = @http_client.delete("tokens/#{token_number}")
          response.json
        end
      end
    end
  end
end
