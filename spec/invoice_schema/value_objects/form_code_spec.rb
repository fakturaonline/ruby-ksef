# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::ValueObjects::FormCode do
  describe "#initialize" do
    it "accepts FA(2)" do
      code = described_class.new(described_class::FA2)
      expect(code.value).to eq("FA(2)")
    end

    it "accepts FA(3)" do
      code = described_class.new(described_class::FA3)
      expect(code.value).to eq("FA(3)")
    end

    it "defaults to FA(2)" do
      code = described_class.new
      expect(code.value).to eq("FA(2)")
    end

    it "raises error for invalid code" do
      expect { described_class.new("FA(4)") }.to raise_error(ArgumentError)
    end
  end

  describe "#schema_version" do
    it "returns schema version" do
      code = described_class.new
      expect(code.schema_version).to eq("1-0E")
    end
  end

  describe "#wariant_formularza" do
    it "returns numeric variant for FA(2)" do
      code = described_class.new(described_class::FA2)
      expect(code.wariant_formularza).to eq(0)
    end

    it "returns numeric variant for FA(3)" do
      code = described_class.new(described_class::FA3)
      expect(code.wariant_formularza).to eq(0)
    end
  end

  describe "#target_namespace" do
    it "returns namespace URL" do
      code = described_class.new
      expect(code.target_namespace).to include("crd.gov.pl")
    end
  end
end
