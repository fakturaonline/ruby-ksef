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
        # @option limits_data [Hash] :online_session Online session limits
        # @option limits_data [Hash] :batch_session Batch session limits
        #
        # Session limits hash can contain:
        # - maxInvoiceSizeInMB [Integer] Max invoice size in MB (RC5.3+, replaces maxInvoiceSizeInMib)
        # - maxInvoiceWithAttachmentSizeInMB [Integer] Max invoice with attachment size in MB (RC5.3+)
        # - maxInvoiceSizeInMib [Integer] (deprecated, will be removed 2025-10-27)
        # - maxInvoiceWithAttachmentSizeInMib [Integer] (deprecated, will be removed 2025-10-27)
        #
        # @return [Hash] Limits response
        def call(limits_data:)
          response = @http_client.post("testdata/limits/context/session", body: limits_data)
          response.json
        end
      end
    end
  end
end
