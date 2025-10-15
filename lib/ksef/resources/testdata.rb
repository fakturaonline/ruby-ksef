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
    end
  end
end
