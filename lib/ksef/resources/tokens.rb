# frozen_string_literal: true

module KSEF
  module Resources
    # Tokens resource for token management
    class Tokens
      def initialize(http_client)
        @http_client = http_client
      end

      # Create a new authentication token
      # @param permissions [Array<String>] Token permissions (InvoiceRead, InvoiceWrite, CredentialsRead, CredentialsManage, SubunitManage, EnforcementOperations)
      # @param description [String] Token description
      # @return [Hash] Response with token reference number
      def create(permissions:, description:)
        Requests::Tokens::CreateHandler.new(@http_client).call(
          permissions: permissions,
          description: description
        )
      end

      # List all tokens
      # @return [Hash] List of tokens
      def list
        Requests::Tokens::ListHandler.new(@http_client).call
      end

      # Get status of a token by reference number
      # @param reference_number [String] Token reference number
      # @return [Hash] Token status information
      def status(reference_number)
        Requests::Tokens::StatusHandler.new(@http_client).call(reference_number)
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
