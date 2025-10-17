# frozen_string_literal: true

module KSEF
  module Resources
    # Testdata resource for managing test data
    class Testdata
      def initialize(http_client)
        @http_client = http_client
      end

      # Create test person
      # @param nip [String] NIP number
      # @param pesel [String] PESEL number
      # @param description [String] Description
      # @param is_bailiff [Boolean] Is bailiff flag (default: false)
      # @param created_date [String, nil] Optional created date (ISO 8601 format)
      # @return [Hash] Creation response
      def person_create(nip:, pesel:, description:, is_bailiff: false, created_date: nil)
        Requests::Testdata::PersonCreateHandler.new(@http_client).call(
          nip: nip,
          pesel: pesel,
          description: description,
          is_bailiff: is_bailiff,
          created_date: created_date
        )
      end

      # Remove test person
      # @param nip [String] NIP number of person to remove
      # @return [Hash] Removal response
      def person_remove(nip:)
        Requests::Testdata::PersonRemoveHandler.new(@http_client).call(nip: nip)
      end

      # Grant test permissions
      # @param grant_data [Hash] Test permissions data with NIP and permissions list
      # @return [Hash] Grant response
      def permissions_grant(grant_data:)
        Requests::Testdata::PermissionsGrantHandler.new(@http_client).call(grant_data: grant_data)
      end

      # Revoke test permissions
      # @param revoke_data [Hash] Revocation data with permission ID
      # @return [Hash] Revocation response
      def permissions_revoke(revoke_data:)
        Requests::Testdata::PermissionsRevokeHandler.new(@http_client).call(revoke_data: revoke_data)
      end

      # Grant test attachment
      # @param attachment_data [Hash] Test attachment data with NIP and attachment details
      # @return [Hash] Grant response
      def attachment_grant(attachment_data:)
        Requests::Testdata::AttachmentGrantHandler.new(@http_client).call(attachment_data: attachment_data)
      end

      # Revoke test attachment
      # @param revoke_data [Hash] Revocation data with attachment ID
      # @return [Hash] Revocation response
      def attachment_revoke(revoke_data:)
        Requests::Testdata::AttachmentRevokeHandler.new(@http_client).call(revoke_data: revoke_data)
      end

      # Set test context session limits
      # @param limits_data [Hash] Limits configuration (max_sessions, max_invoices_per_session)
      # @return [Hash] Limits response
      def limits_context_session(limits_data:)
        Requests::Testdata::LimitsContextSessionHandler.new(@http_client).call(limits_data: limits_data)
      end

      # Set test subject certificate limits
      # @param limits_data [Hash] Limits configuration (subject_identifier, max_certificates)
      # @return [Hash] Limits response
      def limits_subject_certificate(limits_data:)
        Requests::Testdata::LimitsSubjectCertificateHandler.new(@http_client).call(limits_data: limits_data)
      end
    end
  end
end
