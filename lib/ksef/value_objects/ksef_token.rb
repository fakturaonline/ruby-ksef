# frozen_string_literal: true

module KSEF
  module ValueObjects
    # KSEF API token for authentication
    class KsefToken
      attr_reader :token

      def initialize(token)
        @token = token
        validate!
      end

      def to_s
        @token
      end

      def ==(other)
        other.is_a?(self.class) && other.token == @token
      end

      alias eql? ==

      def hash
        @token.hash
      end

      private

      def validate!
        raise ValidationError, "KSEF token cannot be nil or empty" if @token.nil? || @token.empty?
      end
    end
  end
end
