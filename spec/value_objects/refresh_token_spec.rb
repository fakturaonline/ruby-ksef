# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::RefreshToken do
  describe ".new" do
    it "creates refresh token with token and expires_at" do
      expires_at = Time.now + 3600
      token = described_class.new(token: "refresh_token_123", expires_at: expires_at)

      expect(token.token).to eq("refresh_token_123")
      expect(token.expires_at).to eq(expires_at)
      expect(token.to_s).to eq("refresh_token_123")
    end

    it "validates token is not nil" do
      expect {
        described_class.new(token: nil)
      }.to raise_error(KSEF::ValidationError, /cannot be nil or empty/)
    end

    it "allows expires_at to be nil" do
      token = described_class.new(token: "token")
      expect(token.expires_at).to be_nil
    end
  end

  describe "#expired?" do
    it "returns false when token is not expired" do
      token = described_class.new(token: "token", expires_at: Time.now + 3600)
      expect(token.expired?).to be false
    end

    it "returns true when token is expired" do
      token = described_class.new(token: "token", expires_at: Time.now - 3600)
      expect(token.expired?).to be true
    end
  end
end
