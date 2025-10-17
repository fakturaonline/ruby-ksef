# frozen_string_literal: true

module KSEF
  module Resources
    # Permissions resource for managing KSeF permissions
    class Permissions
      def initialize(http_client)
        @http_client = http_client
      end

      # Grant permissions to persons
      # @param grant_data [Hash] Grant data with NIP and persons list
      # @return [Hash] Grant response with reference number
      def grant_persons(grant_data:)
        Requests::Permissions::PersonsGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant permissions to entities
      # @param grant_data [Hash] Grant data with NIP and entities list
      # @return [Hash] Grant response with reference number
      def grant_entities(grant_data:)
        Requests::Permissions::EntitiesGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant authorizations
      # @param grant_data [Hash] Grant data with NIP and authorizations list
      # @return [Hash] Grant response with reference number
      def grant_authorizations(grant_data:)
        Requests::Permissions::AuthorizationsGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant indirect permissions
      # @param grant_data [Hash] Grant data with NIP and indirect grants list
      # @return [Hash] Grant response with reference number
      def grant_indirect(grant_data:)
        Requests::Permissions::IndirectGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant permissions to subunits
      # @param grant_data [Hash] Grant data with NIP and subunits list
      # @return [Hash] Grant response with reference number
      def grant_subunits(grant_data:)
        Requests::Permissions::SubunitsGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant administration permissions to EU entities
      # @param grant_data [Hash] Grant data with tax ID and administrators list
      # @return [Hash] Grant response with reference number
      def grant_eu_entities_administration(grant_data:)
        Requests::Permissions::EuEntitiesAdministrationGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Grant permissions to EU entities
      # @param grant_data [Hash] Grant data with tax ID and EU entities list
      # @return [Hash] Grant response with reference number
      def grant_eu_entities(grant_data:)
        Requests::Permissions::EuEntitiesGrantsHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Revoke a common grant
      # @param permission_id [String] Permission ID to revoke
      # @return [Hash] Revocation response
      def revoke_common_grant(permission_id)
        Requests::Permissions::CommonGrantsRevokeHandler.new(@http_client).call(permission_id)
      end

      # Revoke an authorization grant
      # @param permission_id [String] Permission ID to revoke
      # @return [Hash] Revocation response
      def revoke_authorization_grant(permission_id)
        Requests::Permissions::AuthorizationsGrantsRevokeHandler.new(@http_client).call(permission_id)
      end

      # Check permission operation status
      # @param reference_number [String] Operation reference number
      # @return [Hash] Operation status
      def operation_status(reference_number)
        Requests::Permissions::OperationsStatusHandler.new(@http_client).call(reference_number)
      end

      # Check attachments status
      # @param filters [Hash] Query filters (optional reference_number)
      # @return [Hash] Attachments status
      def attachments_status(filters: {})
        Requests::Permissions::AttachmentsStatusHandler.new(@http_client).call(filters: filters)
      end

      # Query personal grants
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with personal grants
      def query_personal_grants(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QueryPersonalGrantsHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query persons grants
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with persons grants
      def query_persons_grants(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QueryPersonsGrantsHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query subunits grants
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with subunits grants
      def query_subunits_grants(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QuerySubunitsGrantsHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query entities roles
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with entities roles
      def query_entities_roles(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QueryEntitiesRolesHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query subordinate entities roles
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with subordinate entities roles
      def query_subordinate_entities_roles(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QuerySubordinateEntitiesRolesHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query authorizations grants
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with authorizations grants
      def query_authorizations_grants(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QueryAuthorizationsGrantsHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Query EU entities grants
      # @param query_data [Hash] Query filters
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with EU entities grants
      def query_eu_entities_grants(query_data: {}, page_size: nil, page_offset: nil)
        Requests::Permissions::QueryEuEntitiesGrantsHandler.new(@http_client).call(
          query_data: query_data,
          page_size: page_size,
          page_offset: page_offset
        )
      end
    end
  end
end
