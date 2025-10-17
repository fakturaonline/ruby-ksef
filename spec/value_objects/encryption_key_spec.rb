# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::EncryptionKey do
  describe ".new" do
    it "creates encryption key with key and iv" do
      key_bytes = OpenSSL::Random.random_bytes(32)
      iv_bytes = OpenSSL::Random.random_bytes(16)
      key = described_class.new(key: key_bytes, iv: iv_bytes)

      expect(key.key).to eq(key_bytes)
      expect(key.iv).to eq(iv_bytes)
    end

    it "validates key size" do
      expect {
        described_class.new(key: "short", iv: OpenSSL::Random.random_bytes(16))
      }.to raise_error(KSEF::ValidationError, /Encryption key must be 32 bytes/)
    end

    it "validates iv size" do
      expect {
        described_class.new(key: OpenSSL::Random.random_bytes(32), iv: "short")
      }.to raise_error(KSEF::ValidationError, /IV must be 16 bytes/)
    end
  end

  describe ".random" do
    it "generates random encryption key" do
      key = described_class.random

      expect(key.key).to be_a(String)
      expect(key.key.bytesize).to eq(32)
      expect(key.iv.bytesize).to eq(16)
    end
  end

  describe "#==" do
    it "equals another encryption key with same values" do
      key1 = described_class.new(key: OpenSSL::Random.random_bytes(32), iv: OpenSSL::Random.random_bytes(16))
      key2 = described_class.new(key: key1.key, iv: key1.iv)

      expect(key1).to eq(key2)
    end
  end
end
