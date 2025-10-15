# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for sending certificate enrollment request
      class EnrollHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(params)
          body = {
            certificateName: params[:certificate_name],
            certificateType: params[:certificate_type],
            csr: params[:csr]
          }

          response = @http_client.post("certificates/enrollments", body: body)
          response.json
        end
      end
    end
  end
end
