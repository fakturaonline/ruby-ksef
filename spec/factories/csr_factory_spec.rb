# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Factories::CSRFactory do
  describe ".generate" do
    let(:dn) do
      {
        CN: "Test User",
        C: "PL",
        ST: "Mazowieckie",
        L: "Warsaw",
        O: "Test Organization",
        OU: "IT Department"
      }
    end

    context "with EC key (default)" do
      it "generates CSR with EC key" do
        result = described_class.generate(dn)

        expect(result).to be_a(Hash)
        expect(result[:csr]).to be_a(OpenSSL::X509::Request)
        expect(result[:private_key]).to be_a(OpenSSL::PKey::EC)
        expect(result[:pem]).to be_a(String)
      end

      it "uses P-256 curve" do
        result = described_class.generate(dn)

        expect(result[:private_key].group.curve_name).to eq("prime256v1")
      end

      it "sets correct subject" do
        result = described_class.generate(dn)

        subject = result[:csr].subject.to_s
        expect(subject).to include("CN=Test User")
        expect(subject).to include("C=PL")
        expect(subject).to include("ST=Mazowieckie")
        expect(subject).to include("L=Warsaw")
        expect(subject).to include("O=Test Organization")
        expect(subject).to include("OU=IT Department")
      end

      it "sets version 0" do
        result = described_class.generate(dn)

        expect(result[:csr].version).to eq(0)
      end

      it "includes public key" do
        result = described_class.generate(dn)

        expect(result[:csr].public_key).not_to be_nil
        expect(result[:csr].public_key).to be_a(OpenSSL::PKey::EC)
      end

      it "is properly signed" do
        result = described_class.generate(dn)

        # Verify CSR signature
        expect(result[:csr].verify(result[:private_key])).to be true
      end

      it "generates PEM format" do
        result = described_class.generate(dn)

        expect(result[:pem]).to start_with("-----BEGIN CERTIFICATE REQUEST-----")
        expect(result[:pem]).to end_with("-----END CERTIFICATE REQUEST-----\n")

        # Verify PEM can be parsed
        parsed_csr = OpenSSL::X509::Request.new(result[:pem])
        expect(parsed_csr.subject.to_s).to eq(result[:csr].subject.to_s)
      end
    end

    context "with RSA key" do
      it "generates CSR with RSA key" do
        result = described_class.generate(dn, key_type: :rsa)

        expect(result[:csr]).to be_a(OpenSSL::X509::Request)
        expect(result[:private_key]).to be_a(OpenSSL::PKey::RSA)
      end

      it "uses default key size of 2048" do
        result = described_class.generate(dn, key_type: :rsa)

        expect(result[:private_key].n.num_bits).to eq(2048)
      end

      it "accepts custom key size" do
        result = described_class.generate(dn, key_type: :rsa, key_size: 4096)

        expect(result[:private_key].n.num_bits).to eq(4096)
      end

      it "is properly signed" do
        result = described_class.generate(dn, key_type: :rsa)

        expect(result[:csr].verify(result[:private_key])).to be true
      end
    end

    context "with minimal DN" do
      it "generates CSR with only CN" do
        minimal_dn = { CN: "Minimal User" }
        result = described_class.generate(minimal_dn)

        expect(result[:csr].subject.to_s).to eq("/CN=Minimal User")
      end
    end

    context "with string DN keys" do
      it "accepts string keys" do
        string_dn = {
          "CN" => "String User",
          "O" => "String Org"
        }
        result = described_class.generate(string_dn)

        subject = result[:csr].subject.to_s
        expect(subject).to include("CN=String User")
        expect(subject).to include("O=String Org")
      end
    end

    context "error handling" do
      it "raises error for unsupported key type" do
        expect do
          described_class.generate(dn, key_type: :dsa)
        end.to raise_error(ArgumentError, /Unsupported key type: dsa/)
      end

      it "raises error for invalid DN" do
        expect do
          described_class.generate(nil)
        end.to raise_error
      end
    end

    context "consistency" do
      it "generates different keys on each call" do
        result1 = described_class.generate(dn)
        result2 = described_class.generate(dn)

        expect(result1[:private_key].to_der).not_to eq(result2[:private_key].to_der)
        expect(result1[:csr].to_der).not_to eq(result2[:csr].to_der)
      end

      it "maintains same subject for same DN" do
        result1 = described_class.generate(dn)
        result2 = described_class.generate(dn)

        expect(result1[:csr].subject.to_s).to eq(result2[:csr].subject.to_s)
      end
    end

    context "real-world usage" do
      it "generates CSR that can be used for certificate enrollment" do
        result = described_class.generate({
                                            CN: "Jan Kowalski",
                                            C: "PL",
                                            O: "Test Company",
                                            OU: "Finance"
                                          })

        # Verify CSR is valid
        expect(result[:csr].verify(result[:private_key])).to be true

        # Verify can be converted to DER
        der = result[:csr].to_der
        expect(der).not_to be_empty

        # Verify can be base64 encoded (for API submission)
        base64_csr = Base64.strict_encode64(der)
        expect(base64_csr).to be_a(String)

        # Verify can be decoded back
        decoded_der = Base64.decode64(base64_csr)
        decoded_csr = OpenSSL::X509::Request.new(decoded_der)
        expect(decoded_csr.subject.to_s).to eq(result[:csr].subject.to_s)
      end
    end
  end
end
