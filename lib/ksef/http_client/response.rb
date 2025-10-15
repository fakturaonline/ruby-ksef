# frozen_string_literal: true

module KSEF
  module HttpClient
    # HTTP response wrapper
    class Response
      attr_reader :raw_response

      def initialize(raw_response)
        @raw_response = raw_response
      end

      # Get response status code
      def status
        @raw_response.status
      end

      # Get raw response body
      def body
        @raw_response.body
      end

      # Get response headers
      def headers
        @raw_response.headers
      end

      # Parse response body as JSON
      def json
        @json ||= MultiJson.load(body) if body && !body.empty?
      rescue MultiJson::ParseError => e
        raise ApiError, "Failed to parse JSON response: #{e.message}"
      end

      # Check if response was successful
      def success?
        status >= 200 && status < 300
      end

      # Check if response was an error
      def error?
        !success?
      end

      # Raise exception if response was an error
      def raise_on_error!
        return if success?

        error_message = extract_error_message
        case status
        when 400..499
          raise ApiError, "Client error (#{status}): #{error_message}"
        when 500..599
          raise ApiError, "Server error (#{status}): #{error_message}"
        else
          raise ApiError, "Unexpected error (#{status}): #{error_message}"
        end
      end

      private

      def extract_error_message
        return body unless body

        if json
          json["error"] || json["message"] || json["description"] || body
        else
          body
        end
      rescue StandardError
        body
      end
    end
  end
end
