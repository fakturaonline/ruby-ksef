# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::RachunekBankowy do
  describe "#to_rexml" do
    # FA(3) XSD defines only <NrRB> for any account number; the FA(2)-era
    # <NrRBIBAN> branch was removed in the 2025 schema.
    it "emits <NrRB> for an IBAN-formatted account number" do
      rachunek = described_class.new(
        nr_rb: "PL61109010140000071219812874",
        swift: "WBKPPLPP",
        nazwa_banku: "PKO BP"
      )

      xml = rachunek.to_rexml.to_s

      expect(xml).to include("<NrRB>PL61109010140000071219812874</NrRB>")
      expect(xml).not_to include("NrRBIBAN")
      expect(xml).to include("<SWIFT>WBKPPLPP</SWIFT>")
      expect(xml).to include("<NazwaBanku>PKO BP</NazwaBanku>")
    end

    it "emits <NrRB> for a local account number" do
      rachunek = described_class.new(
        nr_rb: "12345678901234567890123456"
      )

      xml = rachunek.to_rexml.to_s

      expect(xml).to include("<NrRB>12345678901234567890123456</NrRB>")
      expect(xml).not_to include("IBAN")
    end
  end
end
