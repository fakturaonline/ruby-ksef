# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for checking attachments status
      class AttachmentsStatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Check attachments status
        # @param filters [Hash] Query filters
        # @option filters [String] :reference_number Optional reference number
        # @return [Hash] Attachments status
        def call(filters: {})
          params = {}
          params[:referenceNumber] = filters[:reference_number] if filters[:reference_number]

          response = @http_client.get("permissions/attachments/status", params: params)
          response.json
        end
      end
    end
  end
end
