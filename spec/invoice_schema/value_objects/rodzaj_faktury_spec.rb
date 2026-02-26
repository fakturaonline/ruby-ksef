# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::ValueObjects::RodzajFaktury do
  describe "#initialize" do
    it "accepts VAT" do
      expect(described_class.new(described_class::VAT).value).to eq("VAT")
    end

    it "accepts KOR (FA(3) correction)" do
      expect(described_class.new(described_class::KOR).value).to eq("KOR")
    end

    it "accepts KOR_ZAL (FA(3) advance correction)" do
      expect(described_class.new(described_class::KOR_ZAL).value).to eq("KOR_ZAL")
    end

    it "accepts KOR_ROZ (FA(3) settlement correction)" do
      expect(described_class.new(described_class::KOR_ROZ).value).to eq("KOR_ROZ")
    end

    it "KOREKTA is an alias for KOR" do
      expect(described_class::KOREKTA).to eq("KOR")
      expect(described_class.new(described_class::KOREKTA).value).to eq("KOR")
    end

    it "accepts ZAL" do
      expect(described_class.new(described_class::ZALICZKOWA).value).to eq("ZAL")
    end

    it "accepts ROZ" do
      expect(described_class.new(described_class::ROZ).value).to eq("ROZ")
    end

    it "accepts UPR" do
      expect(described_class.new(described_class::UPR).value).to eq("UPR")
    end

    it "defaults to VAT" do
      expect(described_class.new.value).to eq("VAT")
    end

    it "raises error for invalid type" do
      expect { described_class.new("INVALID") }.to raise_error(ArgumentError)
    end
  end

  describe "#to_s" do
    it "returns type string" do
      expect(described_class.new("KOR").to_s).to eq("KOR")
    end
  end
end
