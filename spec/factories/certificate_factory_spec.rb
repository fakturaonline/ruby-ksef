# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe KSEF::Factories::CertificateFactory do
  describe ".from_pkcs12" do
    let(:key) { OpenSSL::PKey::RSA.new(2048) }
    let(:certificate) do
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 1
      cert.subject = OpenSSL::X509::Name.parse("/CN=Test/O=Test Org")
      cert.issuer = cert.subject
      cert.public_key = key.public_key
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.sign(key, OpenSSL::Digest.new("SHA256"))
      cert
    end

    context "with valid PKCS12 file" do
      it "loads certificate and private key" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          pkcs12 = OpenSSL::PKCS12.create("test123", "test", key, certificate)
          file.write(pkcs12.to_der)
          file.rewind

          result = described_class.from_pkcs12(file.path, passphrase: "test123")

          expect(result).to be_a(Hash)
          expect(result[:certificate]).to be_a(OpenSSL::X509::Certificate)
          expect(result[:private_key]).to be_a(OpenSSL::PKey::RSA)
          expect(result[:raw]).to be_a(String)
          expect(result[:info]).to be_a(Hash)
        end
      end

      it "extracts certificate info" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          pkcs12 = OpenSSL::PKCS12.create("test123", "test", key, certificate)
          file.write(pkcs12.to_der)
          file.rewind

          result = described_class.from_pkcs12(file.path, passphrase: "test123")

          expect(result[:info][:subject]).to include("CN=Test")
          expect(result[:info][:issuer]).to include("CN=Test")
          expect(result[:info][:serial]).to eq("1")
          expect(result[:info][:not_before]).to be_a(Time)
          expect(result[:info][:not_after]).to be_a(Time)
        end
      end

      it "provides raw certificate without headers" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          pkcs12 = OpenSSL::PKCS12.create("test123", "test", key, certificate)
          file.write(pkcs12.to_der)
          file.rewind

          result = described_class.from_pkcs12(file.path, passphrase: "test123")

          expect(result[:raw]).not_to include("BEGIN CERTIFICATE")
          expect(result[:raw]).not_to include("END CERTIFICATE")
          expect(result[:raw]).not_to include("\n")

          # Verify it's valid base64
          decoded = Base64.decode64(result[:raw])
          expect(decoded).to eq(certificate.to_der)
        end
      end

      it "loads certificate with nil passphrase" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          pkcs12 = OpenSSL::PKCS12.create("", "test", key, certificate)
          file.write(pkcs12.to_der)
          file.rewind

          result = described_class.from_pkcs12(file.path, passphrase: nil)

          expect(result[:certificate]).not_to be_nil
          expect(result[:private_key]).not_to be_nil
        end
      end
    end

    context "with invalid PKCS12 file" do
      it "raises error for wrong passphrase" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          pkcs12 = OpenSSL::PKCS12.create("test123", "test", key, certificate)
          file.write(pkcs12.to_der)
          file.rewind

          expect do
            described_class.from_pkcs12(file.path, passphrase: "wrong")
          end.to raise_error(ArgumentError, /Unable to read the cert file/)
        end
      end

      it "raises error for invalid file" do
        Tempfile.create(["test_cert", ".p12"]) do |file|
          file.write("invalid data")
          file.rewind

          expect do
            described_class.from_pkcs12(file.path, passphrase: "test123")
          end.to raise_error(ArgumentError, /Unable to read the cert file/)
        end
      end
    end

    # Note: EC key tests skipped due to OpenSSL 3.0 incompatibility with cert.public_key = ec_key.public_key
  end

  describe ".from_pem" do
    let(:key) { OpenSSL::PKey::RSA.new(2048) }
    let(:certificate) do
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 1
      cert.subject = OpenSSL::X509::Name.parse("/CN=Test PEM/O=Test Org")
      cert.issuer = cert.subject
      cert.public_key = key.public_key
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.sign(key, OpenSSL::Digest.new("SHA256"))
      cert
    end

    context "with valid PEM files" do
      it "loads certificate and private key" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind
            key_file.write(key.to_pem)
            key_file.rewind

            result = described_class.from_pem(cert_file.path, key_file.path)

            expect(result).to be_a(Hash)
            expect(result[:certificate]).to be_a(OpenSSL::X509::Certificate)
            expect(result[:private_key]).to be_a(OpenSSL::PKey::RSA)
            expect(result[:raw]).to be_a(String)
            expect(result[:info]).to be_a(Hash)
          end
        end
      end

      it "loads encrypted private key with passphrase" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind

            # Encrypt private key
            cipher = OpenSSL::Cipher.new("AES-256-CBC")
            encrypted_key = key.to_pem(cipher, "secret123")
            key_file.write(encrypted_key)
            key_file.rewind

            result = described_class.from_pem(cert_file.path, key_file.path, passphrase: "secret123")

            expect(result[:private_key]).to be_a(OpenSSL::PKey::RSA)
            expect(result[:private_key].to_der).to eq(key.to_der)
          end
        end
      end

      it "extracts certificate info" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind
            key_file.write(key.to_pem)
            key_file.rewind

            result = described_class.from_pem(cert_file.path, key_file.path)

            expect(result[:info][:subject]).to include("CN=Test PEM")
            expect(result[:info][:issuer]).to include("CN=Test PEM")
            expect(result[:info][:serial]).to eq("1")
            expect(result[:info][:not_before]).to be_a(Time)
            expect(result[:info][:not_after]).to be_a(Time)
          end
        end
      end

      it "provides raw certificate without headers" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind
            key_file.write(key.to_pem)
            key_file.rewind

            result = described_class.from_pem(cert_file.path, key_file.path)

            expect(result[:raw]).not_to include("BEGIN CERTIFICATE")
            expect(result[:raw]).not_to include("END CERTIFICATE")
            expect(result[:raw]).not_to include("\n")

            # Verify it's valid base64
            decoded = Base64.decode64(result[:raw])
            expect(decoded).to eq(certificate.to_der)
          end
        end
      end
    end

    context "with invalid PEM files" do
      it "raises error for invalid certificate" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write("invalid certificate")
            cert_file.rewind
            key_file.write(key.to_pem)
            key_file.rewind

            expect do
              described_class.from_pem(cert_file.path, key_file.path)
            end.to raise_error(ArgumentError, /Unable to read the cert file/)
          end
        end
      end

      it "raises error for invalid private key" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind
            key_file.write("invalid key")
            key_file.rewind

            expect do
              described_class.from_pem(cert_file.path, key_file.path)
            end.to raise_error(ArgumentError, /Unable to read the cert file/)
          end
        end
      end

      it "raises error for wrong passphrase" do
        Tempfile.create(["test_cert", ".pem"]) do |cert_file|
          Tempfile.create(["test_key", ".pem"]) do |key_file|
            cert_file.write(certificate.to_pem)
            cert_file.rewind

            cipher = OpenSSL::Cipher.new("AES-256-CBC")
            encrypted_key = key.to_pem(cipher, "secret123")
            key_file.write(encrypted_key)
            key_file.rewind

            expect do
              described_class.from_pem(cert_file.path, key_file.path, passphrase: "wrong")
            end.to raise_error(ArgumentError, /Unable to read the cert file/)
          end
        end
      end
    end

    # Note: EC key tests skipped due to OpenSSL 3.0 incompatibility with cert.public_key = ec_key.public_key
  end
end
