# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::ConvertPemToDer do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:test_data) { "This is test data for PEM to DER conversion" }
    let(:base64_data) { Base64.strict_encode64(test_data) }

    context "with valid PEM format" do
      it "converts PEM to DER format" do
        pem = "-----BEGIN CERTIFICATE-----\n#{base64_data}\n-----END CERTIFICATE-----\n"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end

      it "handles multi-line base64" do
        # Split base64 into multiple lines
        base64_lines = base64_data.scan(/.{1,64}/).join("\n")
        pem = "-----BEGIN CERTIFICATE-----\n#{base64_lines}\n-----END CERTIFICATE-----\n"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end

      it "removes all whitespace" do
        pem = "-----BEGIN CERTIFICATE-----\n  #{base64_data}  \n\n-----END CERTIFICATE-----\n"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end
    end

    context "with different PEM types" do
      it "handles PRIVATE KEY format" do
        pem = "-----BEGIN PRIVATE KEY-----\n#{base64_data}\n-----END PRIVATE KEY-----"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end

      it "handles RSA PRIVATE KEY format" do
        pem = "-----BEGIN RSA PRIVATE KEY-----\n#{base64_data}\n-----END RSA PRIVATE KEY-----"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end

      it "handles CERTIFICATE REQUEST format" do
        pem = "-----BEGIN CERTIFICATE REQUEST-----\n#{base64_data}\n-----END CERTIFICATE REQUEST-----"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end
    end

    context "with real certificate PEM" do
      it "converts actual certificate PEM to DER" do
        key = OpenSSL::PKey::RSA.new(2048)
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.serial = 1
        cert.subject = OpenSSL::X509::Name.parse("/CN=Test")
        cert.issuer = cert.subject
        cert.public_key = key.public_key
        cert.not_before = Time.now
        cert.not_after = Time.now + 365 * 24 * 60 * 60
        cert.sign(key, OpenSSL::Digest.new("SHA256"))

        pem = cert.to_pem
        result = action.call(pem)

        expect(result).to eq(cert.to_der)

        # Verify OpenSSL can parse the result
        parsed_cert = OpenSSL::X509::Certificate.new(result)
        expect(parsed_cert.subject.to_s).to eq(cert.subject.to_s)
      end
    end

    context "with real private key PEM" do
      it "converts private key PEM to DER" do
        key = OpenSSL::PKey::RSA.new(2048)
        pem = key.to_pem
        result = action.call(pem)

        expect(result).to eq(key.to_der)

        # Verify OpenSSL can parse the result
        parsed_key = OpenSSL::PKey::RSA.new(result)
        expect(parsed_key.to_der).to eq(key.to_der)
      end
    end

    context "with various whitespace scenarios" do
      it "handles tabs and spaces" do
        pem = "-----BEGIN CERTIFICATE-----\n\t#{base64_data}  \n-----END CERTIFICATE-----"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end

      it "handles Windows line endings" do
        pem = "-----BEGIN CERTIFICATE-----\r\n#{base64_data}\r\n-----END CERTIFICATE-----"
        result = action.call(pem)

        expect(result).to eq(test_data)
      end
    end
  end
end
