# frozen_string_literal: true

module KSEF
  module Requests
    module Tokens
      # Handler for listing tokens
      class ListHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.get("tokens")
          response.json
        end
      end
    end
  end
end
