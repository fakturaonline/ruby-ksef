# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for granting indirect permissions
      class IndirectGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant indirect permissions
        # @param grant_data [Hash] Grant data
        # @option grant_data [String] :nip NIP of the grantor
        # @option grant_data [Array<Hash>] :indirect_grants List of indirect grants
        # @return [Hash] Grant response with reference number
        def call(grant_data:)
          response = @http_client.post("permissions/indirect/grants", body: grant_data)
          response.json
        end
      end
    end
  end
end
