# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for querying certificates
      class QueryHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query certificates
        # @param filters [Hash] Query filters
        # @option filters [String] :name Optional certificate name
        # @option filters [String] :type Optional certificate type
        # @option filters [String] :status Optional certificate status
        # @option filters [String] :certificate_serial_number Optional certificate serial number
        # @option filters [String] :expires_after Optional expiration date (ISO 8601)
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with certificates
        def call(filters: {}, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          body = {}
          body[:name] = filters[:name] if filters[:name]
          body[:type] = filters[:type] if filters[:type]
          body[:status] = filters[:status] if filters[:status]
          body[:certificateSerialNumber] = filters[:certificate_serial_number] if filters[:certificate_serial_number]
          body[:expiresAfter] = filters[:expires_after] if filters[:expires_after]

          response = @http_client.post("certificates/query", body: body, params: params)
          response.json
        end
      end
    end
  end
end
