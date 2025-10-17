# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for granting permissions to EU entities
      class EuEntitiesGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant permissions to EU entities
        # @param grant_data [Hash] Grant data
        # @option grant_data [String] :tax_id Tax ID of the grantor
        # @option grant_data [Array<Hash>] :entities List of EU entities to grant permissions to
        # @return [Hash] Grant response with reference number
        def call(grant_data:)
          response = @http_client.post("permissions/eu-entities/grants", body: grant_data)
          response.json
        end
      end
    end
  end
end
