# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for checking permission operation status
      class OperationsStatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Check permission operation status
        # @param reference_number [String] Operation reference number
        # @return [Hash] Operation status
        def call(reference_number)
          response = @http_client.get("permissions/operations/#{reference_number}")
          response.json
        end
      end
    end
  end
end
