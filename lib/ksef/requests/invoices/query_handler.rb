# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for querying invoices
      class QueryHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(params)
          response = @http_client.post("invoices/query/metadata", body: params)
          response.json
        end
      end
    end
  end
end
