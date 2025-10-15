# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::AccessToken do
  describe "#initialize" do
    it "accepts token and expiration" do
      expires_at = Time.now + 3600
      token = described_class.new(token: "test_token", expires_at: expires_at)

      expect(token.token).to eq "test_token"
      expect(token.expires_at).to eq expires_at
    end

    it "accepts token without expiration" do
      token = described_class.new(token: "test_token")
      expect(token.expires_at).to be_nil
    end

    it "raises error for empty token" do
      expect { described_class.new(token: "") }.to raise_error(KSEF::ValidationError)
    end
  end

  describe "#expired?" do
    it "returns false for non-expiring token" do
      token = described_class.new(token: "test_token")
      expect(token.expired?).to be false
    end

    it "returns false for future expiration" do
      token = described_class.new(
        token: "test_token",
        expires_at: Time.now + 3600
      )
      expect(token.expired?).to be false
    end

    it "returns true for past expiration" do
      token = described_class.new(
        token: "test_token",
        expires_at: Time.now - 3600
      )
      expect(token.expired?).to be true
    end

    it "considers buffer time" do
      token = described_class.new(
        token: "test_token",
        expires_at: Time.now + 30
      )
      expect(token.expired?(buffer: 60)).to be true
      expect(token.expired?(buffer: 10)).to be false
    end
  end

  describe ".from_hash" do
    it "creates token from API response" do
      hash = {
        "token" => "test_token",
        "validUntil" => "2025-10-15T12:00:00Z"
      }

      token = described_class.from_hash(hash)
      expect(token.token).to eq "test_token"
      expect(token.expires_at).to be_a(Time)
    end
  end
end
