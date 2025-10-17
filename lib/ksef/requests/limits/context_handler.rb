# frozen_string_literal: true

module KSEF
  module Requests
    module Limits
      # Handler for getting context limits
      class ContextHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get context limits
        # @return [Hash] Context limits information
        def call
          response = @http_client.get("limits/context")
          response.json
        end
      end
    end
  end
end
