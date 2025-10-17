# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::KsefToken do
  describe ".new" do
    it "creates KSEF token with token string" do
      token = described_class.new("TOKEN123")

      expect(token.token).to eq("TOKEN123")
      expect(token.to_s).to eq("TOKEN123")
    end

    it "validates token is not nil" do
      expect {
        described_class.new(nil)
      }.to raise_error(KSEF::ValidationError, /cannot be nil or empty/)
    end

    it "validates token is not empty" do
      expect {
        described_class.new("")
      }.to raise_error(KSEF::ValidationError, /cannot be nil or empty/)
    end
  end

  describe "#==" do
    it "equals another token with same value" do
      token1 = described_class.new("TOKEN123")
      token2 = described_class.new("TOKEN123")

      expect(token1).to eq(token2)
    end
  end
end
