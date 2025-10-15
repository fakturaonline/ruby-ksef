# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for revoking a certificate
      class RevokeCertificateHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke a certificate
        # @param certificate_serial_number [String] Certificate serial number
        # @param revocation_reason [String, nil] Optional revocation reason
        # @return [Hash] Revocation response
        def call(certificate_serial_number, revocation_reason: nil)
          body = {}
          body[:revocationReason] = revocation_reason if revocation_reason

          response = @http_client.post("certificates/#{certificate_serial_number}/revoke", body: body)
          response.json
        end
      end
    end
  end
end
