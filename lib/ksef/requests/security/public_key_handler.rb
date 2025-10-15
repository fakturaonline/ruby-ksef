# frozen_string_literal: true

module KSEF
  module Requests
    module Security
      # Handler for fetching KSEF public key certificates
      class PublicKeyHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.get("security/public-key-certificates")
          response.json
        end
      end
    end
  end
end
