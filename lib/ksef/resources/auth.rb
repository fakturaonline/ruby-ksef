# frozen_string_literal: true

module KSEF
  module Resources
    # Authentication resource
    class Auth
      def initialize(http_client)
        @http_client = http_client
      end

      # Get authentication challenge
      # @return [Hash] Challenge response
      def challenge
        Requests::Auth::ChallengeHandler.new(@http_client).call
      end

      # Check authentication status
      # @param reference_number [String] Reference number from auth request
      # @return [Hash] Status response
      def status(reference_number)
        Requests::Auth::StatusHandler.new(@http_client).call(reference_number)
      end

      # Redeem tokens after successful authentication
      # @return [Hash] Tokens response with accessToken and refreshToken
      def redeem
        Requests::Auth::RedeemHandler.new(@http_client).call
      end

      # Refresh access token using refresh token
      # @return [Hash] New access token
      def refresh
        Requests::Auth::RefreshHandler.new(@http_client).call
      end

      # Revoke current session
      # @return [Hash] Revoke response
      def revoke
        Requests::Auth::RevokeHandler.new(@http_client).call
      end

      # List active sessions
      # @param page_size [Integer, nil] Optional page size
      # @param continuation_token [String, nil] Optional continuation token for pagination
      # @return [Hash] List of active sessions
      def sessions_list(page_size: nil, continuation_token: nil)
        Requests::Auth::SessionsListHandler.new(@http_client).call(
          page_size: page_size,
          continuation_token: continuation_token
        )
      end

      # Revoke a specific session by reference number
      # @param reference_number [String] Session reference number
      # @return [Hash] Revocation response
      def sessions_revoke(reference_number)
        Requests::Auth::SessionsRevokeHandler.new(@http_client).call(reference_number)
      end

      # Revoke the current session
      # @return [Hash] Revocation response
      def sessions_revoke_current
        Requests::Auth::SessionsRevokeCurrentHandler.new(@http_client).call
      end
    end
  end
end
