# frozen_string_literal: true

module TestHelpers
  # Stub HTTP client for testing
  def stub_http_client(response_body: {}, status: 200, headers: {})
    http_client = instance_double(KSEF::HttpClient::Client)
    response = instance_double(
      KSEF::HttpClient::Response,
      json: response_body,
      body: response_body.is_a?(String) ? response_body : response_body.to_json,
      status: status,
      headers: headers,
      success?: status >= 200 && status < 300
    )

    allow(http_client).to receive_messages(get: response, post: response, put: response, delete: response,
                                           config: KSEF::Config.new(mode: KSEF::ValueObjects::Mode.new(:test)))

    http_client
  end

  # Create test config
  def test_config(**options)
    defaults = {
      mode: KSEF::ValueObjects::Mode.new(:test),
      access_token: KSEF::ValueObjects::AccessToken.new(
        token: "test_access_token",
        expires_at: Time.now + 3600
      ),
      identifier: KSEF::ValueObjects::NIP.new("1111111111")
    }

    KSEF::Config.new(**defaults, **options)
  end

  # Stub KSEF API response
  def stub_ksef_request(method, path, response_body: {}, status: 200)
    stub_request(method, %r{https://ksef-test\.mf\.gov\.pl/api/#{path}})
      .to_return(
        status: status,
        body: response_body.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  # Create expired access token
  def expired_access_token
    KSEF::ValueObjects::AccessToken.new(
      token: "expired_token",
      expires_at: Time.now - 3600
    )
  end

  # Create valid refresh token
  def valid_refresh_token
    KSEF::ValueObjects::RefreshToken.new(
      token: "refresh_token",
      expires_at: Time.now + 86_400 # 24 hours
    )
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end
