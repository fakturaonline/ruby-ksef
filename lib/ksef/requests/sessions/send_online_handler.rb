# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for sending online invoice
      class SendOnlineHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(reference_number, params)
          body = prepare_body(params)

          response = @http_client.post(
            "sessions/online/#{reference_number}/invoices",
            body: body,
            headers: { "Content-Type" => "application/json" }
          )

          response.json
        end

        private

        def prepare_body(params)
          {
            invoiceHash: params[:invoice_hash],
            invoiceSize: params[:invoice_size],
            encryptedInvoiceHash: params[:encrypted_invoice_hash],
            encryptedInvoiceSize: params[:encrypted_invoice_size],
            encryptedInvoiceContent: params[:encrypted_invoice_content],
            offlineMode: params[:offline_mode] || false
          }.compact
        end
      end
    end
  end
end
