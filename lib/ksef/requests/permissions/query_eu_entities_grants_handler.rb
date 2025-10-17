# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for querying EU entities grants
      class QueryEuEntitiesGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query EU entities grants
        # @param query_data [Hash] Query filters
        # @option query_data [String] :permission_type Optional permission type
        # @option query_data [String] :entity_tax_id Optional entity tax ID
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with grants
        def call(query_data: {}, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          response = @http_client.post("permissions/query/eu-entities/grants", body: query_data, params: params)
          response.json
        end
      end
    end
  end
end
