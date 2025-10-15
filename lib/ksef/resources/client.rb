# frozen_string_literal: true

module KSEF
  module Resources
    # Root client resource providing access to all API endpoints
    class Client
      attr_reader :http_client, :config

      def initialize(http_client, config)
        @http_client = http_client
        @config = config
      end

      # Access authentication endpoints
      # @return [Auth] Auth resource
      def auth
        @auth ||= Auth.new(@http_client)
      end

      # Access session endpoints
      # @return [Sessions] Sessions resource
      def sessions
        refresh_token_if_expired!
        @sessions ||= Sessions.new(@http_client)
      end

      # Access invoice endpoints
      # @return [Invoices] Invoices resource
      def invoices
        refresh_token_if_expired!
        @invoices ||= Invoices.new(@http_client)
      end

      # Access certificate endpoints
      # @return [Certificates] Certificates resource
      def certificates
        refresh_token_if_expired!
        @certificates ||= Certificates.new(@http_client)
      end

      # Access token endpoints
      # @return [Tokens] Tokens resource
      def tokens
        refresh_token_if_expired!
        @tokens ||= Tokens.new(@http_client)
      end

      # Access security endpoints
      # @return [Security] Security resource
      def security
        @security ||= Security.new(@http_client)
      end

      # Get current access token
      def access_token
        @config.access_token
      end

      # Get current refresh token
      def refresh_token
        @config.refresh_token
      end

      # Get current encryption key
      def encryption_key
        @config.encryption_key
      end

      private

      # Automatically refresh access token if expired
      def refresh_token_if_expired!
        return unless @config.access_token
        return unless @config.access_token.expired?(buffer: 60)
        return unless @config.refresh_token&.valid?

        # Temporarily use refresh token as access token
        temp_config = @config.with_access_token(@config.refresh_token)
        temp_client = HttpClient::Client.new(temp_config)

        # Call refresh endpoint
        handler = Requests::Auth::RefreshHandler.new(temp_client)
        response = handler.call

        # Update access token
        new_token = ValueObjects::AccessToken.from_hash(response)
        @config = @config.with_access_token(new_token)
        @http_client.config = @config

        # Log refresh
        @config.logger&.info("Access token refreshed successfully")
      end
    end
  end
end
