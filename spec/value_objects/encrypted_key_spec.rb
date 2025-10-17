# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::EncryptedKey do
  describe ".new" do
    it "creates encrypted key with value" do
      key = described_class.new("base64_encrypted_key")

      expect(key.value).to eq("base64_encrypted_key")
      expect(key.to_s).to eq("base64_encrypted_key")
    end

    it "validates value is not nil" do
      expect {
        described_class.new(nil)
      }.to raise_error(KSEF::ValidationError, /cannot be nil or empty/)
    end

    it "validates value is not empty" do
      expect {
        described_class.new("")
      }.to raise_error(KSEF::ValidationError, /cannot be nil or empty/)
    end
  end

  describe "#==" do
    it "equals another encrypted key with same value" do
      key1 = described_class.new("test123")
      key2 = described_class.new("test123")

      expect(key1).to eq(key2)
    end
  end
end
