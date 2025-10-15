# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for KSEF token authentication
      class KsefTokenHandler
        def initialize(http_client, ksef_token, identifier)
          @http_client = http_client
          @ksef_token = ksef_token
          @identifier = identifier
        end

        def call(challenge_response)
          # Get KSEF public key
          public_key_handler = Security::PublicKeyHandler.new(@http_client)
          public_keys = public_key_handler.call

          # Find symmetric key encryption certificate
          cert_data = public_keys.find { |k| k["usage"] == "SymmetricKeyEncryption" }
          raise Error, "SymmetricKeyEncryption certificate not found" unless cert_data

          # Decrypt certificate and get public key
          cert_der = Base64.decode64(cert_data["certificate"])
          certificate = OpenSSL::X509::Certificate.new(cert_der)
          public_key = certificate.public_key

          # Create payload: TOKEN|TIMESTAMP
          payload = "#{@ksef_token.token}|#{challenge_response['timestamp']}"

          # Encrypt with RSA-OAEP
          encrypted = public_key.public_encrypt(
            payload,
            OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING
          )

          # Base64 encode
          encrypted_token = Base64.strict_encode64(encrypted)

          # Send authentication request
          body = {
            contextIdentifierGroup: {
              identifierGroup: {
                nip: @identifier.value
              }
            },
            encryptedToken: encrypted_token
          }

          response = @http_client.post("auth/ksef-token", body: body)
          response.json
        end
      end
    end
  end
end
