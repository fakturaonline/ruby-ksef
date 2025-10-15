# frozen_string_literal: true

module KSEF
  module Requests
    module Certificates
      # Handler for retrieving certificates
      class RetrieveHandler
        def initialize(http_client)
          @http_client = http_client
        end

        def call(serial_numbers)
          body = { certificateSerialNumbers: serial_numbers }

          response = @http_client.post("certificates/retrieve", body: body)
          response.json
        end
      end
    end
  end
end
