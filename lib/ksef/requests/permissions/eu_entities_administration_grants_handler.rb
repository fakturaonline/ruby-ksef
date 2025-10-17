# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for granting administration permissions to EU entities
      class EuEntitiesAdministrationGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant administration permissions to EU entities
        # @param grant_data [Hash] Grant data
        # @option grant_data [String] :tax_id Tax ID of the EU entity
        # @option grant_data [Array<Hash>] :administrators List of administrators
        # @return [Hash] Grant response with reference number
        def call(grant_data:)
          response = @http_client.post("permissions/eu-entities/administration/grants", body: grant_data)
          response.json
        end
      end
    end
  end
end
