# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for checking enrollment status
      class EnrollmentStatusHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(reference_number)
          response = @http_client.get("certificates/enrollments/#{reference_number}")
          response.json
        end
      end
    end
  end
end
