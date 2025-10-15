# frozen_string_literal: true

module KSEF
  module ValueObjects
    # AES-256 encryption key with IV
    class EncryptionKey
      attr_reader :key, :iv

      def initialize(key:, iv:)
        @key = key
        @iv = iv
        validate!
      end

      # Generate random encryption key
      def self.random
        new(
          key: OpenSSL::Random.random_bytes(32),
          iv: OpenSSL::Random.random_bytes(16)
        )
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.key == @key &&
          other.iv == @iv
      end

      alias eql? ==

      def hash
        [@key, @iv].hash
      end

      private

      def validate!
        raise ValidationError, "Encryption key must be 32 bytes" if @key.nil? || @key.bytesize != 32
        raise ValidationError, "IV must be 16 bytes" if @iv.nil? || @iv.bytesize != 16
      end
    end
  end
end
