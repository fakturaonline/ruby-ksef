# frozen_string_literal: true

module KSEF
  module Actions
    # High-level action for sending invoice online with automatic encryption and session management
    class SendInvoiceOnline
      def initialize(client)
        @client = client
        @http_client = client.instance_variable_get(:@http_client)
      end

      # Send invoice with automatic encryption and session management
      # @param invoice_xml [String] Invoice XML content
      # @return [Hash] Response with referenceNumber and session details
      def call(invoice_xml)
        # 1. Get public key certificate for symmetric key encryption
        certificate = get_encryption_certificate

        # 2. Generate AES-256 encryption key
        encryption_key = Factories::EncryptionKeyFactory.generate_random

        # 3. Encrypt AES key with RSA public key
        key_encryptor = Actions::EncryptKey.new(certificate['certificate'])
        encrypted_aes_key = key_encryptor.call(encryption_key)
        init_vector = Base64.strict_encode64(encryption_key.iv)

        # 4. Open online session with encrypted key
        session_response = @client.sessions.open_online(
          invoice_version: 'FA (3)',  # KSeF 2.0 requires FA(3)
          encryption_info: {
            encrypted_key: encrypted_aes_key,
            init_vector:   init_vector
          }
        )
        session_ref = session_response['referenceNumber']

        # 5. Encrypt invoice content with AES
        encryptor = Actions::EncryptDocument.new(encryption_key)
        encrypted_content = encryptor.call(invoice_xml)
        encrypted_content_base64 = Base64.strict_encode64(encrypted_content)

        # 6. Calculate hashes
        invoice_hash = Digest::SHA256.base64digest(invoice_xml)
        encrypted_hash = Digest::SHA256.base64digest(encrypted_content)

        # 7. Send encrypted invoice
        response = @client.sessions.send_online(
          session_ref,
          invoice_hash:              invoice_hash,
          invoice_size:              invoice_xml.bytesize,
          encrypted_invoice_hash:    encrypted_hash,
          encrypted_invoice_size:    encrypted_content.bytesize,
          encrypted_invoice_content: encrypted_content_base64
        )

        # 8. Return response with session info
        response.merge(
          'sessionReferenceNumber' => session_ref,
          'xmlContent' => invoice_xml
        )
      end

      private

      def get_encryption_certificate
        certificates = @client.security.public_key_certificates

        # Find certificate for SymmetricKeyEncryption
        cert = certificates.find { |c| c['usage']&.include?('SymmetricKeyEncryption') }

        raise Error, 'No SymmetricKeyEncryption certificate found' unless cert

        cert
      end
    end
  end
end
