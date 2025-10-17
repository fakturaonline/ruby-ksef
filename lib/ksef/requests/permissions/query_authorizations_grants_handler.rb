# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for querying authorizations grants
      class QueryAuthorizationsGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query authorizations grants
        # @param query_data [Hash] Query filters
        # @option query_data [String] :permission_type Optional permission type
        # @option query_data [String] :authorization_identifier Optional authorization identifier
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with grants
        def call(query_data: {}, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          response = @http_client.post("permissions/query/authorizations/grants", body: query_data, params: params)
          response.json
        end
      end
    end
  end
end
