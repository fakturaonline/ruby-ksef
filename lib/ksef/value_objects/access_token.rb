# frozen_string_literal: true

module KSEF
  module ValueObjects
    # JWT access token with expiration tracking
    class AccessToken
      attr_reader :token, :expires_at

      def initialize(token:, expires_at: nil)
        @token = token
        @expires_at = expires_at
        validate!
      end

      # Create from KSEF API response hash
      # @param hash [Hash] Response hash with 'token' and 'validUntil' keys
      def self.from_hash(hash)
        new(
          token: hash["token"],
          expires_at: hash["validUntil"] ? Time.parse(hash["validUntil"]) : nil
        )
      end

      # Check if token is expired
      # @param buffer [Integer] Seconds before expiration to consider expired (default: 60)
      def expired?(buffer: 60)
        return false if @expires_at.nil?

        @expires_at <= Time.now + buffer
      end

      # Check if token is valid (not expired)
      def valid?(buffer: 60)
        !expired?(buffer: buffer)
      end

      def to_s
        @token
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.token == @token &&
          other.expires_at == @expires_at
      end

      alias eql? ==

      def hash
        [@token, @expires_at].hash
      end

      private

      def validate!
        raise ValidationError, "Token cannot be nil or empty" if @token.nil? || @token.empty?
      end
    end
  end
end
