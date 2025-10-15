# frozen_string_literal: true

module KSEF
  module Actions
    # Action for encrypting documents with AES-256-CBC
    class EncryptDocument
      def initialize(encryption_key)
        @encryption_key = encryption_key
      end

      def call(document)
        cipher = OpenSSL::Cipher.new("AES-256-CBC")
        cipher.encrypt
        cipher.key = @encryption_key.key
        cipher.iv = @encryption_key.iv

        cipher.update(document) + cipher.final
      end
    end
  end
end
