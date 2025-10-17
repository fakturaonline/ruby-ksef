# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for granting test attachments
      class AttachmentGrantHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant test attachment
        # @param attachment_data [Hash] Test attachment data
        # @option attachment_data [String] :nip NIP of the test entity
        # @option attachment_data [Hash] :attachment Attachment details
        # @return [Hash] Grant response
        def call(attachment_data:)
          response = @http_client.post("testdata/attachment", body: attachment_data)
          response.json
        end
      end
    end
  end
end
