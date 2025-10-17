# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for revoking test attachments
      class AttachmentRevokeHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Revoke test attachment
        # @param revoke_data [Hash] Revocation data
        # @option revoke_data [String] :attachment_id Attachment ID to revoke
        # @return [Hash] Revocation response
        def call(revoke_data:)
          response = @http_client.post("testdata/attachment/revoke", body: revoke_data)
          response.json
        end
      end
    end
  end
end
