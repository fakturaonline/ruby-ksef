# frozen_string_literal: true

module KSEF
  module Resources
    # Invoices resource for querying and downloading
    class Invoices
      def initialize(http_client)
        @http_client = http_client
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
    end
  end
end
