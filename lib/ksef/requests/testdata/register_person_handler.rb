# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for registering test person in KSeF test environment
      class RegisterPersonHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Register a test person
        # @param nip [String] NIP number
        # @param pesel [String] PESEL number
        # @param description [String] Description
        # @param is_bailiff [Boolean] Is bailiff (default: false)
        # @return [Hash] Response
        def call(nip:, pesel:, description: nil, is_bailiff: false)
          body = {
            nip: nip,
            pesel: pesel,
            description: description || "Test person #{nip}",
            isBailiff: is_bailiff
          }

          response = @http_client.post("testdata/person", body: body)
          response.json
        end

        # Remove test person
        # @param nip [String] NIP number
        # @return [Hash] Response
        def remove(nip:)
          body = { nip: nip }
          response = @http_client.delete("testdata/person/remove", body: body)
          response.json
        end
      end
    end
  end
end
