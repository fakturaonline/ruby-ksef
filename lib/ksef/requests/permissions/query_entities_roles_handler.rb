# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for querying entities roles
      class QueryEntitiesRolesHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query entities roles
        # @param query_data [Hash] Query filters
        # @option query_data [String] :entity_nip Optional entity NIP
        # @option query_data [String] :role_type Optional role type
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with roles
        def call(query_data: {}, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          response = @http_client.post("permissions/query/entities/roles", body: query_data, params: params)
          response.json
        end
      end
    end
  end
end
