# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for getting certificate limits
      class LimitsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get certificate limits
        # @return [Hash] Certificate limits information
        def call
          response = @http_client.get("certificates/limits")
          response.json
        end
      end
    end
  end
end
