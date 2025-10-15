# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Adres do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      adres = described_class.new(
        kod_kraju: "PL",
        miejscowosc: "Warszawa",
        kod_pocztowy: "00-001",
        ulica: "Testowa",
        nr_domu: "123",
        nr_lokalu: "45",
        wojewodztwo: "mazowieckie",
        powiat: "warsz

awski",
        gmina: "Warszawa"
      )

      doc = adres.to_rexml
      expect(doc.root.name).to eq("Adres")
      expect(doc.root.elements["KodKraju"].text).to eq("PL")
      expect(doc.root.elements["Miejscowosc"].text).to eq("Warszawa")
      expect(doc.root.elements["Ulica"].text).to eq("Testowa")
    end

    it "generates XML with minimal fields" do
      adres = described_class.new(
        kod_kraju: "PL",
        miejscowosc: "Kraków"
      )

      doc = adres.to_rexml
      expect(doc.root.elements["KodKraju"].text).to eq("PL")
      expect(doc.root.elements["Miejscowosc"].text).to eq("Kraków")
      expect(doc.root.elements["Ulica"]).to be_nil
    end
  end

  describe ".from_nokogiri" do
    it "parses XML with all fields" do
      xml = <<~XML
        <Adres>
          <KodKraju>PL</KodKraju>
          <Miejscowosc>Warszawa</Miejscowosc>
          <KodPocztowy>00-001</KodPocztowy>
          <Ulica>Testowa</Ulica>
          <NrDomu>123</NrDomu>
          <NrLokalu>45</NrLokalu>
        </Adres>
      XML

      doc = Nokogiri::XML(xml)
      adres = described_class.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.miejscowosc).to eq("Warszawa")
      expect(adres.kod_pocztowy).to eq("00-001")
      expect(adres.ulica).to eq("Testowa")
      expect(adres.nr_domu).to eq("123")
      expect(adres.nr_lokalu).to eq("45")
    end

    it "handles minimal XML" do
      xml = "<Adres><KodKraju>PL</KodKraju><Miejscowosc>Kraków</Miejscowosc></Adres>"
      doc = Nokogiri::XML(xml)
      adres = described_class.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.miejscowosc).to eq("Kraków")
      expect(adres.ulica).to be_nil
    end
  end

  describe "round-trip conversion" do
    it "preserves data through XML conversion" do
      original = described_class.new(
        kod_kraju: "PL",
        miejscowosc: "Poznań",
        kod_pocztowy: "60-001",
        ulica: "Główna",
        nr_domu: "10"
      )

      xml = original.to_rexml.to_s
      doc = Nokogiri::XML(xml)
      parsed = described_class.from_nokogiri(doc.root)

      expect(parsed.kod_kraju).to eq(original.kod_kraju)
      expect(parsed.miejscowosc).to eq(original.miejscowosc)
      expect(parsed.kod_pocztowy).to eq(original.kod_pocztowy)
      expect(parsed.ulica).to eq(original.ulica)
      expect(parsed.nr_domu).to eq(original.nr_domu)
    end
  end
end
