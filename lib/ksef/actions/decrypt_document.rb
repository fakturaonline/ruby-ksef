# frozen_string_literal: true

module KSEF
  module Actions
    # Action for decrypting documents with AES-256-CBC
    class DecryptDocument
      def initialize(encryption_key)
        @encryption_key = encryption_key
      end

      def call(encrypted_document)
        cipher = OpenSSL::Cipher.new("AES-256-CBC")
        cipher.decrypt
        cipher.key = @encryption_key.key
        cipher.iv = @encryption_key.iv

        decrypted = cipher.update(encrypted_document) + cipher.final
        decrypted
      end
    end
  end
end
