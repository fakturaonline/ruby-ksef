# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for creating test person data
      class PersonCreateHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Create test person
        # @param nip [String] NIP number
        # @param pesel [String] PESEL number
        # @param description [String] Description
        # @param is_bailiff [Boolean] Is bailiff flag (default: false)
        # @param created_date [String, nil] Optional created date (ISO 8601 format)
        # @return [Hash] Creation response
        def call(nip:, pesel:, description:, is_bailiff: false, created_date: nil)
          body = {
            nip: nip,
            pesel: pesel,
            description: description,
            isBailiff: is_bailiff
          }
          body[:createdDate] = created_date if created_date

          # Testdata endpoints don't require authentication
          response = @http_client.post("testdata/person", body: body, skip_auth: true)
          response.json
        end
      end
    end
  end
end
