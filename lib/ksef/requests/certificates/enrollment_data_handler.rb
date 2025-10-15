# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for getting enrollment data
      class EnrollmentDataHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call
          response = @http_client.get("certificates/enrollments/data")
          response.json
        end
      end
    end
  end
end
