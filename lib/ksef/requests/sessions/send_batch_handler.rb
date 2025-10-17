# frozen_string_literal: true

module KSEF
  module Requests
    module Sessions
      # Handler for opening batch session and uploading invoice package
      class SendBatchHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Open batch session with encrypted invoice package
        # @param params [Hash] Batch session parameters
        # @option params [Hash] :form_code Form code details (systemCode, schemaVersion, value)
        # @option params [Hash] :batch_file Batch file metadata (fileSize, fileHash, fileParts array)
        # @option params [Hash] :encryption Encryption details (encryptedSymmetricKey, initializationVector)
        # @option params [Boolean] :offline_mode Offline mode flag (optional)
        # @return [Hash] Session reference and upload URLs for parts
        def call(params)
          body = prepare_body(params)

          response = @http_client.post(
            "sessions/batch",
            body: body,
            headers: { "Content-Type" => "application/json" }
          )

          response.json
        end

        private

        def prepare_body(params)
          {
            formCode: params[:form_code],
            batchFile: params[:batch_file],
            encryption: params[:encryption],
            offlineMode: params[:offline_mode] || false
          }.compact
        end
      end
    end
  end
end
