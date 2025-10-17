# frozen_string_literal: true

module KSEF
  module Requests
    module Limits
      # Handler for getting subject limits
      class SubjectHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Get subject limits
        # @return [Hash] Subject limits information
        def call
          response = @http_client.get("limits/subject")
          response.json
        end
      end
    end
  end
end
