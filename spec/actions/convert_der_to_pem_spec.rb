# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::ConvertDerToPem do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:test_data) { "This is test data for DER to PEM conversion" }
    let(:der_data) { test_data }

    context "with default name (CERTIFICATE)" do
      it "converts DER to PEM format" do
        result = action.call(der_data)

        expect(result).to start_with("-----BEGIN CERTIFICATE-----\n")
        expect(result).to end_with("-----END CERTIFICATE-----\n")

        # Extract base64 part and verify it matches original data
        base64_content = result.gsub(/-----BEGIN CERTIFICATE-----\n/, "")
                               .gsub(/-----END CERTIFICATE-----\n/, "")
                               .gsub(/\n/, "")
        decoded = Base64.decode64(base64_content)
        expect(decoded).to eq(der_data)
      end

      it "splits base64 into 64-character lines" do
        long_data = "A" * 200
        result = action.call(long_data)

        lines = result.split("\n")
        lines[1..-2].each do |line|
          expect(line.length).to be <= 64
        end
      end
    end

    context "with custom name" do
      it "uses custom name in PEM headers" do
        result = action.call(der_data, name: "PRIVATE KEY")

        expect(result).to start_with("-----BEGIN PRIVATE KEY-----\n")
        expect(result).to end_with("-----END PRIVATE KEY-----\n")
      end

      it "works with other block names" do
        result = action.call(der_data, name: "RSA PRIVATE KEY")

        expect(result).to start_with("-----BEGIN RSA PRIVATE KEY-----\n")
        expect(result).to end_with("-----END RSA PRIVATE KEY-----\n")
      end
    end

    context "with real certificate DER" do
      it "converts actual certificate DER to PEM" do
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

        der = cert.to_der
        result = action.call(der)

        # Verify OpenSSL can parse the result
        parsed_cert = OpenSSL::X509::Certificate.new(result)
        expect(parsed_cert.to_der).to eq(cert.to_der)
      end
    end
  end
end
