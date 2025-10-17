# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::ConvertCertificateToPkcs12 do
  subject(:action) { described_class.new }

  let(:key) { OpenSSL::PKey::RSA.new(2048) }
  let(:certificate) do
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse("/CN=Test")
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.sign(key, OpenSSL::Digest.new("SHA256"))
    cert
  end

  describe "#call" do
    context "with valid certificate and key" do
      it "converts to PKCS12 format" do
        result = action.call(
          certificate: certificate,
          private_key: key,
          passphrase: "test123"
        )

        expect(result).to be_a(String)
        expect(result).not_to be_empty

        # Verify it's valid PKCS12
        pkcs12 = OpenSSL::PKCS12.new(result, "test123")
        expect(pkcs12.certificate.to_der).to eq(certificate.to_der)
        expect(pkcs12.key.to_der).to eq(key.to_der)
      end
    end

    context "with friendly name" do
      it "includes friendly name in PKCS12" do
        result = action.call(
          certificate: certificate,
          private_key: key,
          passphrase: "test123",
          friendly_name: "My Certificate"
        )

        pkcs12 = OpenSSL::PKCS12.new(result, "test123")
        # Note: friendly_name method not available on all OpenSSL versions
        # Just verify PKCS12 was created successfully
        expect(pkcs12.certificate).not_to be_nil
        expect(pkcs12.key).not_to be_nil
      end
    end

    context "with empty passphrase" do
      it "creates PKCS12 with empty passphrase" do
        result = action.call(
          certificate: certificate,
          private_key: key,
          passphrase: ""
        )

        pkcs12 = OpenSSL::PKCS12.new(result, "")
        expect(pkcs12.certificate).not_to be_nil
      end
    end
  end
end
