# frozen_string_literal: true

module KSEF
  module Requests
    module Tokens
      # Handler for creating authentication tokens
      class CreateHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Create a new authentication token
        # @param permissions [Array<String>] Token permissions
        #   Valid permissions: InvoiceRead, InvoiceWrite, CredentialsRead, CredentialsManage,
        #   SubunitManage, EnforcementOperations, VatUeManage (RC5+)
        # @param description [String] Token description
        # @return [Hash] Response with token reference number
        def call(permissions:, description:)
          body = {
            permissions: permissions,
            description: description
          }

          response = @http_client.post("tokens", body: body)
          response.json
        end
      end
    end
  end
end
