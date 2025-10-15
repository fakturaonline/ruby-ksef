# frozen_string_literal: true

module KSEF
  module Resources
    # Sessions resource for invoice operations
    class Sessions
      def initialize(http_client)
        @http_client = http_client
      end

      # Send online invoice
      # @param params [Hash] Invoice parameters
      # @return [Hash] Send response
      def send_online(params)
        Requests::Sessions::SendOnlineHandler.new(@http_client).call(params)
      end

      # Send batch invoices
      # @param params [Hash] Batch parameters with invoices array
      # @return [Hash] Batch send response
      def send_batch(params)
        Requests::Sessions::SendBatchHandler.new(@http_client).call(params)
      end

      # Check session status
      # @param reference_number [String] Session reference number
      # @return [Hash] Session status
      def status(reference_number)
        Requests::Sessions::StatusHandler.new(@http_client).call(reference_number)
      end

      # Terminate session
      # @param reference_number [String] Session reference number
      # @return [Hash] Terminate response
      def terminate(reference_number)
        Requests::Sessions::TerminateHandler.new(@http_client).call(reference_number)
      end
    end
  end
end
