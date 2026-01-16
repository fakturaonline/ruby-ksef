# frozen_string_literal: true

module KSEF
  module Actions
    # Action for encrypting AES key with RSA public key
    class EncryptKey
      def initialize(certificate_base64)
        # Decode base64 certificate and extract public key
        cert_der = Base64.decode64(certificate_base64)
        cert = OpenSSL::X509::Certificate.new(cert_der)
        @public_key = cert.public_key
      end

      # Encrypt AES key using RSAES-OAEP with SHA-256
      # @param encryption_key [ValueObjects::EncryptionKey] AES key to encrypt
      # @return [String] Base64 encoded encrypted key
      def call(encryption_key)
        # Encrypt using RSAES-OAEP with SHA-256 and MGF1-SHA-256
        # OpenSSL 3.0+ supports specifying hash and MGF algorithms
        encrypted = @public_key.encrypt(
          encryption_key.key,
          {
            "rsa_padding_mode" => "oaep",
            "rsa_oaep_md" => "SHA256",
            "rsa_mgf1_md" => "SHA256"
          }
        )

        Base64.strict_encode64(encrypted)
      end
    end
  end
end
