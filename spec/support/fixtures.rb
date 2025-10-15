# frozen_string_literal: true

module Fixtures
  # Challenge response fixture
  def challenge_response_fixture
    {
      "challenge" => Base64.strict_encode64("test_challenge_#{Time.now.to_i}"),
      "timestamp" => Time.now.utc.iso8601
    }
  end

  # Auth response fixture (after sending xades or ksef token)
  def auth_response_fixture
    {
      "referenceNumber" => "20250115-SE-#{SecureRandom.hex(10).upcase}",
      "authenticationToken" => "Bearer #{SecureRandom.hex(32)}"
    }
  end

  # Auth status response fixture
  def auth_status_response_fixture(code: 200)
    {
      "referenceNumber" => "20250115-SE-#{SecureRandom.hex(10).upcase}",
      "status" => {
        "code" => code,
        "description" => code == 200 ? "OK" : "Processing"
      }
    }
  end

  # Token redeem response fixture
  def redeem_token_response_fixture
    {
      "accessToken" => {
        "token" => "Bearer #{SecureRandom.hex(32)}",
        "validUntil" => (Time.now + 3600).utc.iso8601
      },
      "refreshToken" => {
        "token" => "Bearer #{SecureRandom.hex(32)}",
        "validUntil" => (Time.now + 86_400).utc.iso8601
      }
    }
  end

  # Refresh token response fixture
  def refresh_token_response_fixture
    {
      "token" => "Bearer #{SecureRandom.hex(32)}",
      "validUntil" => (Time.now + 3600).utc.iso8601
    }
  end

  # Online invoice send response fixture
  def send_online_response_fixture
    {
      "referenceNumber" => "20250115-SE-#{SecureRandom.hex(10).upcase}",
      "invoiceNumber" => "FV/2025/#{rand(1000..9999)}",
      "timestamp" => Time.now.utc.iso8601
    }
  end

  # Session status response fixture
  def session_status_response_fixture(code: 200)
    base = {
      "referenceNumber" => "20250115-SE-#{SecureRandom.hex(10).upcase}",
      "status" => {
        "code" => code,
        "description" => code == 200 ? "Accepted" : "Processing"
      },
      "timestamp" => Time.now.utc.iso8601
    }

    base["ksefNumber"] = "1111111111-20250115-#{SecureRandom.hex(6).upcase}-#{rand(10..99)}" if code == 200

    base
  end

  # Invoice query response fixture
  def invoice_query_response_fixture(count: 3)
    {
      "invoices" => Array.new(count) do |i|
        {
          "ksefNumber" => "1111111111-20250115-#{SecureRandom.hex(6).upcase}-#{i + 1}",
          "invoiceNumber" => "FV/2025/#{1000 + i}",
          "amount" => rand(100..999).to_f,
          "currency" => "PLN",
          "date" => (Date.today - rand(30)).iso8601
        }
      end,
      "totalCount" => count
    }
  end

  # Error response fixture
  def error_response_fixture(code: 400, message: "Bad Request")
    {
      "error" => {
        "code" => code,
        "message" => message,
        "timestamp" => Time.now.utc.iso8601
      }
    }
  end

  # Public key certificates fixture
  def public_key_certificates_fixture
    [
      {
        "usage" => "SymmetricKeyEncryption",
        "certificate" => Base64.strict_encode64("FAKE_CERT_DER_DATA"),
        "serialNumber" => "12345678"
      },
      {
        "usage" => "Signing",
        "certificate" => Base64.strict_encode64("FAKE_CERT_DER_DATA_2"),
        "serialNumber" => "87654321"
      }
    ]
  end

  # Invoice XML fixture
  def invoice_xml_fixture
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Faktura xmlns="http://crd.gov.pl/wzor/2023/06/29/12648/">
        <Naglowek>
          <KodFormularza kodSystemowy="FA (2)" wersjaSchemy="1-0E">FA</KodFormularza>
          <WariantFormularza>2</WariantFormularza>
          <DataWytworzeniaFa>#{Time.now.strftime("%Y-%m-%dT%H:%M:%S")}</DataWytworzeniaFa>
          <SystemInfo>Test System</SystemInfo>
        </Naglowek>
        <Podmiot1>
          <DaneIdentyfikacyjne>
            <NIP>1111111111</NIP>
            <Nazwa>Test Company</Nazwa>
          </DaneIdentyfikacyjne>
        </Podmiot1>
        <Fa>
          <P_1>#{Time.now.strftime("%Y-%m-%d")}</P_1>
          <P_2>#{Time.now.strftime("%Y-%m-%d")}</P_2>
          <P_13_1>1000.00</P_13_1>
        </Fa>
      </Faktura>
    XML
  end
end

RSpec.configure do |config|
  config.include Fixtures
end
