# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for listing active sessions
      class SessionsListHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # List active sessions
        # @param page_size [Integer, nil] Optional page size
        # @param continuation_token [String, nil] Optional continuation token for pagination
        # @return [Hash] List of active sessions
        def call(page_size: nil, continuation_token: nil)
          params = {}
          params[:pageSize] = page_size if page_size

          headers = {}
          headers["x-continuation-token"] = continuation_token if continuation_token

          response = @http_client.get("auth/sessions", params: params, headers: headers)
          response.json
        end
      end
    end
  end
end
