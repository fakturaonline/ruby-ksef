# frozen_string_literal: true

module KSEF
  module HttpClient
    # HTTP client wrapper around Faraday
    class Client
      attr_accessor :config

      def initialize(config)
        @config = config
        @connection = build_connection
      end

      # Send HTTP request
      # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
      # @param path [String] Request path
      # @param body [Hash, String, nil] Request body
      # @param headers [Hash] Additional headers
      # @return [Response] Response object
      def request(method:, path:, body: nil, headers: {}, params: {})
        log_request(method, path, body, headers, params)

        response = @connection.public_send(method) do |req|
          req.url path
          req.headers.merge!(build_headers(headers))
          req.params.merge!(params) if params.any?
          req.body = prepare_body(body) if body
        end

        wrapped_response = Response.new(response)
        log_response(wrapped_response)
        wrapped_response.raise_on_error!
        wrapped_response
      rescue Faraday::Error => e
        handle_faraday_error(e)
      end

      # Send GET request
      def get(path, params: {}, headers: {})
        request(method: :get, path: path, params: params, headers: headers)
      end

      # Send POST request
      def post(path, body: nil, headers: {}, params: {})
        request(method: :post, path: path, body: body, headers: headers, params: params)
      end

      # Send PUT request
      def put(path, body: nil, headers: {}, params: {})
        request(method: :put, path: path, body: body, headers: headers, params: params)
      end

      # Send DELETE request
      def delete(path, headers: {})
        request(method: :delete, path: path, headers: headers)
      end

      # Send multiple requests concurrently
      # @param requests [Array<Hash>] Array of request hashes
      # @return [Array<Response>] Array of responses
      def send_async(requests)
        # TODO: Implement parallel requests using Faraday's parallel adapter
        # For now, fall back to sequential processing
        requests.map do |req|
          request(
            method: req[:method],
            path: req[:path],
            body: req[:body],
            headers: req[:headers] || {}
          )
        end
      end

      private

      def build_connection
        Faraday.new(url: @config.api_url) do |f|
          f.request :url_encoded
          f.adapter Faraday.default_adapter
          f.options.timeout = 60
          f.options.open_timeout = 30
        end
      end

      def build_headers(additional_headers = {})
        headers = {
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }

        # Add authorization header if access token exists
        headers["Authorization"] = "Bearer #{@config.access_token.token}" if @config.access_token

        # Add encrypted key header if exists
        headers["EncryptedKey"] = @config.encrypted_key.to_s if @config.encrypted_key

        headers.merge(additional_headers)
      end

      def prepare_body(body)
        case body
        when String
          body
        when Hash
          MultiJson.dump(body)
        else
          body.to_s
        end
      end

      def log_request(method, path, body, headers, params)
        return unless @config.logger

        @config.logger.debug("KSEF Request: #{method.upcase} #{path}")

        # Log Authorization header status
        if @config.access_token
          @config.logger.debug("Authorization: Bearer #{@config.access_token.token[0..30]}...")
        else
          @config.logger.debug("Authorization: NONE")
        end

        @config.logger.debug("Headers: #{headers}") if headers.any?
        @config.logger.debug("Params: #{params}") if params.any?
        @config.logger.debug("Body: #{body}") if body
      end

      def log_response(response)
        return unless @config.logger

        @config.logger.debug("KSEF Response: #{response.status}")
        @config.logger.debug("Body: #{response.body}")
      end

      def handle_faraday_error(error)
        case error
        when Faraday::TimeoutError
          raise NetworkError, "Request timeout: #{error.message}"
        when Faraday::ConnectionFailed
          raise NetworkError, "Connection failed: #{error.message}"
        else
          raise NetworkError, "Network error: #{error.message}"
        end
      end
    end
  end
end
