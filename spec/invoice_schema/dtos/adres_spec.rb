# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Adres do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      adres = described_class.new(
        kod_kraju: "PL",
        miejscowosc: "Warszawa",
        kod_pocztowy: "00-001",
        ulica: "Marszałkowska",
        nr_domu: "1",
        nr_lokalu: "10",
        wojewodztwo: "Mazowieckie",
        powiat: "Warszawa",
        gmina: "Śródmieście"
      )

      xml = adres.to_rexml.to_s

      expect(xml).to include("<KodKraju>PL</KodKraju>")
      expect(xml).to include("<Miejscowosc>Warszawa</Miejscowosc>")
      expect(xml).to include("<KodPocztowy>00-001</KodPocztowy>")
      expect(xml).to include("<Ulica>Marszałkowska</Ulica>")
      expect(xml).to include("<NrDomu>1</NrDomu>")
      expect(xml).to include("<NrLokalu>10</NrLokalu>")
      expect(xml).to include("<Wojewodztwo>Mazowieckie</Wojewodztwo>")
    end

    it "generates XML with only required fields" do
      adres = described_class.new(
        kod_kraju: "CZ",
        miejscowosc: "Praha"
      )

      xml = adres.to_rexml.to_s

      expect(xml).to include("<KodKraju>CZ</KodKraju>")
      expect(xml).to include("<Miejscowosc>Praha</Miejscowosc>")
      expect(xml).not_to include("<Ulica>")
      expect(xml).not_to include("<NrDomu>")
    end
  end
end
