# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::RachunekBankowy do
  describe "#to_rexml" do
    it "generates XML with IBAN" do
      rachunek = described_class.new(
        nr_rb: "PL61109010140000071219812874",
        swift: "WBKPPLPP",
        nazwa_banku: "PKO BP"
      )

      xml = rachunek.to_rexml.to_s

      expect(xml).to include("<NrRBIBAN>PL61109010140000071219812874</NrRBIBAN>")
      expect(xml).to include("<SWIFT>WBKPPLPP</SWIFT>")
      expect(xml).to include("<NazwaBanku>PKO BP</NazwaBanku>")
    end

    it "generates XML with local account number" do
      rachunek = described_class.new(
        nr_rb: "12345678901234567890123456"
      )

      xml = rachunek.to_rexml.to_s

      expect(xml).to include("<NrRB>12345678901234567890123456</NrRB>")
      expect(xml).not_to include("IBAN")
    end

    it "detects IBAN by format" do
      iban_rachunek = described_class.new(nr_rb: "CZ6508000000192000145399")
      local_rachunek = described_class.new(nr_rb: "123456789")

      expect(iban_rachunek.to_rexml.to_s).to include("NrRBIBAN")
      expect(local_rachunek.to_rexml.to_s).to include("<NrRB>")
    end
  end
end
