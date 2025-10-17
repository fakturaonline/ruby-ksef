# frozen_string_literal: true

module KSEF
  module Requests
    module Testdata
      # Handler for setting test subject certificate limits
      class LimitsSubjectCertificateHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Set test subject certificate limits
        # @param limits_data [Hash] Limits configuration
        # @option limits_data [String] :subject_identifier Subject identifier (NIP)
        # @option limits_data [Integer] :max_certificates Maximum number of certificates
        # @return [Hash] Limits response
        def call(limits_data:)
          response = @http_client.post("testdata/limits/subject/certificate", body: limits_data)
          response.json
        end
      end
    end
  end
end
