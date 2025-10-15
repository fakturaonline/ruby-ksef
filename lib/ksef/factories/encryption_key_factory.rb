# frozen_string_literal: true

module KSEF
  module Factories
    # Factory for generating encryption keys
    class EncryptionKeyFactory
      # Generate a random encryption key for AES-256-CBC
      # @return [ValueObjects::EncryptionKey] Encryption key with random key and IV
      def self.generate_random
        key = SecureRandom.random_bytes(32) # 256 bits for AES-256
        iv = SecureRandom.random_bytes(16)  # 128 bits for AES block size

        ValueObjects::EncryptionKey.new(key: key, iv: iv)
      end
    end
  end
end
