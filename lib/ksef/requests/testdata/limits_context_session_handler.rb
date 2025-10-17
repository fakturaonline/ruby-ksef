# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for setting test context session limits
      class LimitsContextSessionHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Set test context session limits
        # @param limits_data [Hash] Limits configuration
        # @option limits_data [Integer] :max_sessions Maximum number of sessions
        # @option limits_data [Integer] :max_invoices_per_session Maximum invoices per session
        # @return [Hash] Limits response
        def call(limits_data:)
          response = @http_client.post("testdata/limits/context/session", body: limits_data)
          response.json
        end
      end
    end
  end
end
