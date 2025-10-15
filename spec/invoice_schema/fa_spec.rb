# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::Fa do
  let(:fa_wiersz) do
    KSEF::InvoiceSchema::DTOs::FaWiersz.new(
      nr_wiersza: 1,
      p_7: "Test",
      p_9b: 1000.00,
      p_11: 23,
      p_12: 230.00
    )
  end

  describe "#initialize" do
    it "accepts KodWaluty as object" do
      kod = KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN")
      fa = described_class.new(
        kod_waluty: kod,
        p_1: Date.new(2024, 1, 15),
        p_2: "FV/001",
        p_15: 1230.00
      )

      expect(fa.kod_waluty).to be_a(KSEF::InvoiceSchema::ValueObjects::KodWaluty)
    end

    it "accepts currency as string" do
      fa = described_class.new(
        kod_waluty: "EUR",
        p_1: Date.new(2024, 1, 15),
        p_2: "FV/001",
        p_15: 1230.00
      )

      expect(fa.kod_waluty.value).to eq("EUR")
    end

    it "accepts date as string" do
      fa = described_class.new(
        kod_waluty: "PLN",
        p_1: "2024-01-15",
        p_2: "FV/001",
        p_15: 1230.00,
        p_6: "2024-01-10"
      )

      expect(fa.p_1).to be_a(Date)
      expect(fa.p_6).to be_a(Date)
    end
  end

  describe "#to_rexml" do
    it "generates XML with all fields" do
      platnosc = KSEF::InvoiceSchema::DTOs::Platnosc.new(
        termin_platnosci: KSEF::InvoiceSchema::DTOs::TerminPlatnosci.new(
          termin: Date.new(2024, 2, 15)
        )
      )

      fa = described_class.new(
        kod_waluty: "PLN",
        p_1: Date.new(2024, 1, 15),
        p_1m: "Warszawa",
        p_2: "FV/001",
        p_6: Date.new(2024, 1, 15),
        p_15: 1230.00,
        fa_wiersz: [fa_wiersz],
        p_13_1: 1000.00,
        p_13_2: 230.00,
        platnosc: platnosc
      )

      xml = fa.to_rexml.to_s

      expect(xml).to include("<KodWaluty>PLN</KodWaluty>")
      expect(xml).to include("<P_1>2024-01-15</P_1>")
      expect(xml).to include("<P_1M>Warszawa</P_1M>")
      expect(xml).to include("<P_2>FV/001</P_2>")
      expect(xml).to include("<P_6>2024-01-15</P_6>")
      expect(xml).to include("<P_15>1230.00</P_15>")
      expect(xml).to include("<P_13_1>1000.00</P_13_1>")
      expect(xml).to include("<P_13_2>230.00</P_13_2>")
      expect(xml).to include("<FaWiersz>")
      expect(xml).to include("<Platnosc>")
    end

    it "generates XML without optional fields" do
      fa = described_class.new(
        kod_waluty: "PLN",
        p_1: Date.new(2024, 1, 15),
        p_2: "FV/001",
        p_15: 1230.00
      )

      xml = fa.to_rexml.to_s

      expect(xml).to include("<Fa>")
      expect(xml).not_to include("<P_1M>")
      expect(xml).not_to include("<P_6>")
      expect(xml).not_to include("<Platnosc>")
    end
  end
end
