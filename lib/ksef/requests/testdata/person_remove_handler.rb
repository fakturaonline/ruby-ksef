# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for removing test person data
      class PersonRemoveHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Remove test person
        # @param nip [String] NIP number of person to remove
        # @return [Hash] Removal response
        def call(nip:)
          body = {
            nip: nip
          }

          # Testdata endpoints don't require authentication
          response = @http_client.post("testdata/person/remove", body: body, skip_auth: true)
          response.json
        end
      end
    end
  end
end
