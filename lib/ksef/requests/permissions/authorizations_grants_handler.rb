# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for granting authorizations
      class AuthorizationsGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant authorizations
        # @param grant_data [Hash] Grant data
        # @option grant_data [String] :nip NIP of the grantor
        # @option grant_data [Array<Hash>] :authorizations List of authorizations to grant
        # @return [Hash] Grant response with reference number
        def call(grant_data:)
          response = @http_client.post("permissions/authorizations/grants", body: grant_data)
          response.json
        end
      end
    end
  end
end
