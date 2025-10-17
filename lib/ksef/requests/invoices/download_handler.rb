# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for downloading invoice
      class DownloadHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(ksef_number)
          response = @http_client.get("invoices/ksef/#{ksef_number}")
          response.body
        end
      end
    end
  end
end
