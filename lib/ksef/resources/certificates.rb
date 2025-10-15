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
    end
  end
end
