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

    it "generates XML with PESEL" do
      dane = described_class.new(
        pesel: "12345678901",
        nazwa: "Jan Kowalski"
      )

      xml = dane.to_rexml.to_s

      expect(xml).to include("<PESEL>12345678901</PESEL>")
      expect(xml).to include("<Nazwa>Jan Kowalski</Nazwa>")
    end

    it "generates XML with other ID" do
      dane = described_class.new(
        id_inny: { typ: "1", numer: "ABC123" },
        nazwa: "Foreign Company"
      )

      xml = dane.to_rexml.to_s

      expect(xml).to include("<BrakID>")
      expect(xml).to include("<Typ>1</Typ>")
      expect(xml).to include("<Numer>ABC123</Numer>")
      expect(xml).to include("<Nazwa>Foreign Company</Nazwa>")
    end
  end
end
