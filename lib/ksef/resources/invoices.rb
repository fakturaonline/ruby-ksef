# frozen_string_literal: true

module KSEF
  module Resources
    # Invoices resource for querying and downloading
    class Invoices
      def initialize(http_client, config)
        @http_client = http_client
        @config = config
      end

      # Download invoice by KSEF number
      # @param ksef_number [String] KSEF invoice number
      # @return [String] Invoice XML content (possibly encrypted)
      def download(ksef_number)
        Requests::Invoices::DownloadHandler.new(@http_client).call(ksef_number)
      end

      # Query invoices
      # @param params [Hash] Query parameters
      # @return [Hash] Query response with invoice list
      def query(params)
        Requests::Invoices::QueryHandler.new(@http_client).call(params)
      end

      # Get invoice status
      # @param ksef_number [String] KSEF invoice number
      # @return [Hash] Invoice status
      def status(ksef_number)
        Requests::Invoices::StatusHandler.new(@http_client).call(ksef_number)
      end

      # Initialize invoice export
      # @param filters [Hash] Export filters (see ExportsInitHandler for details)
      # @param include_metadata [Boolean] Include _metadata.json in export package (RC5.3)
      # @return [Hash] Export initialization response with reference number
      def exports_init(filters:, include_metadata: false)
        Requests::Invoices::ExportsInitHandler.new(@http_client, @config).call(
          filters: filters,
          include_metadata: include_metadata
        )
      end

      # Get status of an invoice export
      # @param reference_number [String] Export reference number (replaces operation_reference_number in RC5.3)
      # @return [Hash] Export status information
      def exports_status(reference_number)
        Requests::Invoices::ExportsStatusHandler.new(@http_client).call(reference_number)
      end

      # @deprecated Use {#exports_status} instead (operation_reference_number renamed to reference_number in RC5.3)
      alias exports_status_by_operation exports_status

      # Query invoice metadata
      # @param filters [Hash] Query filters (see QueryMetadataHandler for details)
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @param sort_order [String, nil] Optional sort order (asc, desc) - RC5.4
      # @return [Hash] Query results with invoice metadata
      def query_metadata(filters:, page_size: nil, page_offset: nil, sort_order: nil)
        Requests::Invoices::QueryMetadataHandler.new(@http_client).call(
          filters: filters,
          page_size: page_size,
          page_offset: page_offset,
          sort_order: sort_order
        )
      end
    end
  end
end
