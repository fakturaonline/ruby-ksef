# frozen_string_literal: true

module KSEF
  module Requests
    module Peppol
      # Handler for querying PEPPOL data
      class QueryHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query PEPPOL data
        # @param query_data [Hash] Query filters
        # @option query_data [String] :participant_id Optional PEPPOL participant ID
        # @option query_data [String] :document_type Optional document type
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with PEPPOL data
        def call(query_data: {}, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          response = @http_client.post("peppol/query", body: query_data, params: params)
          response.json
        end
      end
    end
  end
end
