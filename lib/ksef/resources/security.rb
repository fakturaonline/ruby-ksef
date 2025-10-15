# frozen_string_literal: true

module KSEF
  module Resources
    # Security resource for public keys and certificates
    class Security
      def initialize(http_client)
        @http_client = http_client
      end

      # Get KSEF public key certificates
      # @return [Array<Hash>] Public key certificates
      def public_keys
        Requests::Security::PublicKeyHandler.new(@http_client).call
      end
    end
  end
end
