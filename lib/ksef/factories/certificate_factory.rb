# frozen_string_literal: true

module KSEF
  module Factories
    # Factory for creating and loading certificates
    # Based on grafinet/xades-tools logic
    class CertificateFactory
      # Load certificate from PKCS12 file
      # @param path [String] Path to PKCS12 file
      # @param passphrase [String, nil] Optional passphrase
      # @return [Hash] Hash with :certificate, :private_key, :raw, and :info
      def self.from_pkcs12(path, passphrase: nil)
        pkcs12_data = File.read(path)
        pkcs12 = OpenSSL::PKCS12.new(pkcs12_data, passphrase)

        certificate = pkcs12.certificate
        private_key = pkcs12.key

        # Get raw certificate (base64 without headers)
        raw = certificate.to_pem
                        .gsub("-----BEGIN CERTIFICATE-----\n", '')
                        .gsub("\n-----END CERTIFICATE-----\n", '')
                        .gsub("\n", '')

        # Parse certificate info
        info = {
          issuer: certificate.issuer.to_s,
          subject: certificate.subject.to_s,
          serial: certificate.serial.to_s,
          not_before: certificate.not_before,
          not_after: certificate.not_after
        }

        {
          certificate: certificate,
          private_key: private_key,
          raw: raw,
          info: info
        }
      rescue OpenSSL::PKCS12::PKCS12Error => e
        raise ArgumentError, "Unable to read the cert file. OpenSSL: #{e.message}"
      end

      # Load certificate from PEM file
      # @param cert_path [String] Path to certificate PEM file
      # @param key_path [String] Path to private key PEM file
      # @param passphrase [String, nil] Optional passphrase for private key
      # @return [Hash] Hash with :certificate, :private_key, :raw, and :info
      def self.from_pem(cert_path, key_path, passphrase: nil)
        cert_pem = File.read(cert_path)
        key_pem = File.read(key_path)

        certificate = OpenSSL::X509::Certificate.new(cert_pem)
        private_key = OpenSSL::PKey.read(key_pem, passphrase)

        # Get raw certificate (base64 without headers)
        raw = certificate.to_pem
                        .gsub("-----BEGIN CERTIFICATE-----\n", '')
                        .gsub("\n-----END CERTIFICATE-----\n", '')
                        .gsub("\n", '')

        # Parse certificate info
        info = {
          issuer: certificate.issuer.to_s,
          subject: certificate.subject.to_s,
          serial: certificate.serial.to_s,
          not_before: certificate.not_before,
          not_after: certificate.not_after
        }

        {
          certificate: certificate,
          private_key: private_key,
          raw: raw,
          info: info
        }
      rescue OpenSSL::X509::CertificateError, OpenSSL::PKey::PKeyError => e
        raise ArgumentError, "Unable to read the cert file. OpenSSL: #{e.message}"
      end
    end
  end
end
