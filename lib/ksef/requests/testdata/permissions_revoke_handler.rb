# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for revoking test permissions
      class PermissionsRevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke test permissions
        # @param revoke_data [Hash] Revocation data
        # @option revoke_data [String] :permission_id Permission ID to revoke
        # @return [Hash] Revocation response
        def call(revoke_data:)
          response = @http_client.post("testdata/permissions/revoke", body: revoke_data)
          response.json
        end
      end
    end
  end
end
