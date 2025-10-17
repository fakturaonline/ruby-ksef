# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for revoking common grants
      class CommonGrantsRevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke a common grant
        # @param permission_id [String] Permission ID to revoke
        # @return [Hash] Revocation response
        def call(permission_id)
          response = @http_client.delete("permissions/common/grants/#{permission_id}")
          response.json
        end
      end
    end
  end
end
