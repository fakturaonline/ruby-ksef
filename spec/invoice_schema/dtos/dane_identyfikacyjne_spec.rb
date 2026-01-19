# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne do
  describe "#to_rexml" do
    it "generates XML with NIP" do
      dane = described_class.new(
        nip: "1234567890",
        nazwa: "Test Firma"
      )

      xml = dane.to_rexml.to_s

      expect(xml).to include("<NIP>1234567890</NIP>")
      expect(xml).to include("<Nazwa>Test Firma</Nazwa>")
    end

    it "generates XML with BrakID" do
      dane = described_class.new(
        brak_id: 1,
        nazwa: "Individual without tax ID"
      )

      xml = dane.to_rexml.to_s

      expect(xml).to include("<BrakID>1</BrakID>")
      expect(xml).to include("<Nazwa>Individual without tax ID</Nazwa>")
    end

    it "generates XML with other ID" do
      dane = described_class.new(
        kod_kraju: "US",
        nr_id: "ABC123",
        nazwa: "Foreign Company"
      )

      xml = dane.to_rexml.to_s

      expect(xml).to include("<KodKraju>US</KodKraju>")
      expect(xml).to include("<NrID>ABC123</NrID>")
      expect(xml).to include("<Nazwa>Foreign Company</Nazwa>")
    end
  end
end
