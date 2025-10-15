# frozen_string_literal: true

module KSEF
  module Resources
    # Certificates resource for certificate management
    class Certificates
      def initialize(http_client)
        @http_client = http_client
      end

      # Get enrollment data for certificate generation
      # @return [Hash] Enrollment data with DN information
      def enrollment_data
        Requests::Certificates::EnrollmentDataHandler.new(@http_client).call
      end

      # Send certificate enrollment request
      # @param params [Hash] Enrollment parameters with CSR
      # @return [Hash] Enrollment response with reference number
      def enroll(params)
        Requests::Certificates::EnrollHandler.new(@http_client).call(params)
      end

      # Check enrollment status
      # @param reference_number [String] Enrollment reference number
      # @return [Hash] Enrollment status
      def enrollment_status(reference_number)
        Requests::Certificates::EnrollmentStatusHandler.new(@http_client).call(reference_number)
      end

      # Retrieve generated certificate
      # @param serial_numbers [Array<String>] Certificate serial numbers
      # @return [Hash] Certificates data
      def retrieve(serial_numbers)
        Requests::Certificates::RetrieveHandler.new(@http_client).call(serial_numbers)
      end

      # Get certificate limits
      # @return [Hash] Certificate limits information
      def limits
        Requests::Certificates::LimitsHandler.new(@http_client).call
      end

      # Query certificates
      # @param filters [Hash] Query filters (name, type, status, certificate_serial_number, expires_after)
      # @param page_size [Integer, nil] Optional page size
      # @param page_offset [Integer, nil] Optional page offset
      # @return [Hash] Query results with certificates
      def query(filters: {}, page_size: nil, page_offset: nil)
        Requests::Certificates::QueryHandler.new(@http_client).call(
          filters: filters,
          page_size: page_size,
          page_offset: page_offset
        )
      end

      # Revoke a certificate
      # @param certificate_serial_number [String] Certificate serial number
      # @param revocation_reason [String, nil] Optional revocation reason
      # @return [Hash] Revocation response
      def revoke(certificate_serial_number, revocation_reason: nil)
        Requests::Certificates::RevokeCertificateHandler.new(@http_client).call(
          certificate_serial_number,
          revocation_reason: revocation_reason
        )
      end
    end
  end
end
