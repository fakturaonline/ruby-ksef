# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Platnosc do
  let(:termin) do
    KSEF::InvoiceSchema::DTOs::TerminPlatnosci.new(
      termin: Date.new(2024, 2, 15),
      forma_platnosci: "6"
    )
  end

  let(:rachunek) do
    KSEF::InvoiceSchema::DTOs::RachunekBankowy.new(
      nr_rb: "PL61109010140000071219812874",
      swift: "WBKPPLPP"
    )
  end

  describe "#to_rexml" do
    it "generates XML with all components" do
      platnosc = described_class.new(
        termin_platnosci: termin,
        rachunek_bankowy: rachunek,
        forma_platnosci: "6"
      )

      xml = platnosc.to_rexml.to_s

      expect(xml).to include("<Platnosc>")
      expect(xml).to include("<TerminPlatnosci>")
      expect(xml).to include("<RachunekBankowy>")
      expect(xml).to include("<FormaPlatnosci>6</FormaPlatnosci>")
    end

    it "generates XML with multiple payment terms" do
      termin2 = KSEF::InvoiceSchema::DTOs::TerminPlatnosci.new(
        termin: Date.new(2024, 3, 15)
      )

      platnosc = described_class.new(
        termin_platnosci: [termin, termin2]
      )

      xml = platnosc.to_rexml.to_s

      expect(xml.scan("<TerminPlatnosci>").count).to eq(2)
    end

    it "generates XML with multiple bank accounts" do
      rachunek2 = KSEF::InvoiceSchema::DTOs::RachunekBankowy.new(
        nr_rb: "12345678901234567890123456"
      )

      platnosc = described_class.new(
        rachunek_bankowy: [rachunek, rachunek2]
      )

      xml = platnosc.to_rexml.to_s

      expect(xml.scan("<RachunekBankowy>").count).to eq(2)
    end
  end
end
