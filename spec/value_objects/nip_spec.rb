# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::NIP do
  describe "#initialize" do
    it "accepts valid NIP" do
      nip = described_class.new("1234567890")
      expect(nip.value).to eq "1234567890"
    end

    it "normalizes NIP with dashes" do
      nip = described_class.new("123-456-78-90")
      expect(nip.value).to eq "1234567890"
    end

    it "accepts test NIP" do
      nip = described_class.new("1111111111")
      expect(nip.value).to eq "1111111111"
    end

    it "raises error for empty NIP" do
      expect { described_class.new("") }.to raise_error(KSEF::ValidationError)
    end

    it "raises error for too short NIP" do
      expect { described_class.new("123") }.to raise_error(KSEF::ValidationError, /10 digits/)
    end

    it "raises error for invalid checksum" do
      expect { described_class.new("1234567891") }.to raise_error(KSEF::ValidationError, /invalid/)
    end
  end

  describe "#to_s" do
    it "returns NIP as string" do
      nip = described_class.new("1234567890")
      expect(nip.to_s).to eq "1234567890"
    end
  end

  describe "equality" do
    it "is equal for same NIP" do
      nip1 = described_class.new("1111111111")
      nip2 = described_class.new("1111111111")
      expect(nip1).to eq nip2
    end

    it "is not equal for different NIP" do
      nip1 = described_class.new("1111111111")
      nip2 = described_class.new("2222222222")
      expect(nip1).not_to eq nip2
    end
  end
end
