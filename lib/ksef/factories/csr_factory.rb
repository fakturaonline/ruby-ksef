# frozen_string_literal: true

module KSEF
  module Factories
    # Factory for creating Certificate Signing Requests (CSR)
    class CSRFactory
      # Generate a CSR with a new private key
      # @param dn [Hash] Distinguished Name attributes
      # @option dn [String] :CN Common Name
      # @option dn [String] :C Country
      # @option dn [String] :ST State/Province
      # @option dn [String] :L Locality
      # @option dn [String] :O Organization
      # @option dn [String] :OU Organizational Unit
      # @param key_type [Symbol] Key type (:rsa or :ec)
      # @param key_size [Integer] Key size (default: 2048 for RSA, ignored for EC)
      # @return [Hash] Hash with :csr (OpenSSL::X509::Request) and :private_key
      def self.generate(dn, key_type: :ec, key_size: 2048)
        # Generate private key
        private_key = case key_type
                      when :rsa
                        OpenSSL::PKey::RSA.new(key_size)
                      when :ec
                        # P-256 curve (secp256r1)
                        key = OpenSSL::PKey::EC.new('prime256v1')
                        key.generate_key
                        key
                      else
                        raise ArgumentError, "Unsupported key type: #{key_type}. Use :rsa or :ec"
                      end

        # Create CSR
        csr = OpenSSL::X509::Request.new
        csr.version = 0
        csr.subject = OpenSSL::X509::Name.new(dn.map { |k, v| [k.to_s, v] })
        csr.public_key = private_key.public_key

        # Sign CSR with private key
        csr.sign(private_key, OpenSSL::Digest::SHA256.new)

        {
          csr: csr,
          private_key: private_key,
          pem: csr.to_pem
        }
      rescue OpenSSL::X509::RequestError => e
        raise ArgumentError, "Unable to generate CSR. OpenSSL: #{e.message}"
      end
    end
  end
end
