# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for sending batch invoices
      class SendBatchHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(params)
          # TODO: Implement batch invoice sending with ZIP files
          # This is a placeholder implementation

          response = @http_client.post(
            "batch/invoices/send",
            body: params,
            headers: { "Content-Type" => "application/json" }
          )

          response.json
        end
      end
    end
  end
end
