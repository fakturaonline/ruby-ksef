# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for revoking authorization grants
      class AuthorizationsGrantsRevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke an authorization grant
        # @param permission_id [String] Permission ID to revoke
        # @return [Hash] Revocation response
        def call(permission_id)
          response = @http_client.delete("permissions/authorizations/grants/#{permission_id}")
          response.json
        end
      end
    end
  end
end
