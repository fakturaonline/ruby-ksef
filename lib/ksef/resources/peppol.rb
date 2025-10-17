# frozen_string_literal: true

module KSEF
  module Resources
    # PEPPOL resource for querying PEPPOL data
    class Peppol
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
      def query(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Peppol::QueryHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end
    end
  end
end
