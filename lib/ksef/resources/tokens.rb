# frozen_string_literal: true

module KSEF
  module Resources
    # Tokens resource for token management
    class Tokens
      def initialize(http_client)
        @http_client = http_client
      end

      # List all tokens
      # @return [Hash] List of tokens
      def list
        Requests::Tokens::ListHandler.new(@http_client).call
      end

      # Revoke specific token
      # @param token_number [String] Token number to revoke
      # @return [Hash] Revoke response
      def revoke(token_number)
        Requests::Tokens::RevokeHandler.new(@http_client).call(token_number)
      end
    end
  end
end
