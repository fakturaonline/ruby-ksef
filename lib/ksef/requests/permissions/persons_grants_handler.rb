# frozen_string_literal: true

module KSEF
  module Requests
    module Permissions
      # Handler for granting permissions to persons
      class PersonsGrantsHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Grant permissions to persons
        # @param grant_data [Hash] Grant data
        # @option grant_data [String] :nip NIP of the grantor
        # @option grant_data [Array<Hash>] :persons List of persons to grant permissions to
        # @return [Hash] Grant response with reference number
        def call(grant_data:)
          response = @http_client.post("permissions/persons/grants", body: grant_data)
          response.json
        end
      end
    end
  end
end
