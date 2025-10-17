# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::CertificatePath do
  describe ".new" do
    it "creates certificate path with path and passphrase" do
      path = __FILE__
      cert_path = described_class.new(path: path, passphrase: "password123")

      expect(cert_path.path).to eq(path)
      expect(cert_path.passphrase).to eq("password123")
    end

    it "validates path exists" do
      expect {
        described_class.new(path: "/nonexistent/path.pem", passphrase: "pass")
      }.to raise_error(KSEF::ValidationError, /does not exist/)
    end

    it "validates passphrase is not nil" do
      expect {
        described_class.new(path: __FILE__, passphrase: nil)
      }.to raise_error(KSEF::ValidationError, /Passphrase cannot be nil/)
    end
  end

  describe "#exists?" do
    it "returns true for existing file" do
      cert_path = described_class.new(path: __FILE__, passphrase: "pass")
      expect(cert_path.exists?).to be true
    end
  end
end
