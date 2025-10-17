# frozen_string_literal: true

module KSEF
  module Resources
    # Limits resource for getting KSeF limits
    class Limits
      def initialize(http_client)
        @http_client = http_client
      end

      # Get context limits
      # @return [Hash] Context limits information
      def context
        Requests::Limits::ContextHandler.new(@http_client).call
      end

      # Get subject limits
      # @return [Hash] Subject limits information
      def subject
        Requests::Limits::SubjectHandler.new(@http_client).call
      end
    end
  end
end
