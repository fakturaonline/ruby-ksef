# frozen_string_literal: true

module KSEF
  module Actions
    # Action for converting certificate and private key to PKCS12 format
    class ConvertCertificateToPkcs12
      # Convert certificate to PKCS12 format
      # @param certificate [OpenSSL::X509::Certificate] Certificate object
      # @param private_key [OpenSSL::PKey] Private key object
      # @param passphrase [String] Passphrase for PKCS12
      # @param friendly_name [String, nil] Optional friendly name
      # @return [String] PKCS12-encoded data
      def call(certificate:, private_key:, passphrase:, friendly_name: nil)
        pkcs12 = OpenSSL::PKCS12.create(
          passphrase,
          friendly_name,
          private_key,
          certificate
        )

        pkcs12.to_der
      end
    end
  end
end
