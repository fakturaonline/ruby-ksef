# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for sending online invoice
      class SendOnlineHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(params)
          body = prepare_body(params)

          response = @http_client.post(
            "online/invoices/send",
            body: body,
            headers: { "Content-Type" => "application/json" }
          )

          response.json
        end

        private

        def prepare_body(params)
          {
            invoiceHash: params[:invoice_hash],
            invoicePayload: params[:invoice_payload]
          }
        end
      end
    end
  end
end
