# frozen_string_literal: true

module KSEF
  module ValueObjects
    # RSA-encrypted encryption key (base64 encoded)
    class EncryptedKey
      attr_reader :value

      def initialize(value)
        @value = value
        validate!
      end

      def to_s
        @value
      end

      def ==(other)
        other.is_a?(self.class) && other.value == @value
      end

      alias eql? ==

      def hash
        @value.hash
      end

      private

      def validate!
        raise ValidationError, "Encrypted key cannot be nil or empty" if @value.nil? || @value.empty?
      end
    end
  end
end
