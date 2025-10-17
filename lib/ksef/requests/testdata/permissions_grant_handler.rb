# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for granting test permissions
      class PermissionsGrantHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant test permissions
        # @param grant_data [Hash] Test permissions data
        # @option grant_data [String] :nip NIP of the test entity
        # @option grant_data [Array<Hash>] :permissions List of permissions to grant
        # @return [Hash] Grant response
        def call(grant_data:)
          response = @http_client.post("testdata/permissions", body: grant_data)
          response.json
        end
      end
    end
  end
end
