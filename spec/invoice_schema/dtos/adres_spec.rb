# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Adres do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      adres = described_class.new(
        kod_kraju: "PL",
        adres_l1: "Testowa 123/45",
        adres_l2: "00-001 Warszawa",
        gln: "1234567890123"
      )

      doc = adres.to_rexml
      expect(doc.root.name).to eq("Adres")
      expect(doc.root.elements["KodKraju"].text).to eq("PL")
      expect(doc.root.elements["AdresL1"].text).to eq("Testowa 123/45")
      expect(doc.root.elements["AdresL2"].text).to eq("00-001 Warszawa")
      expect(doc.root.elements["GLN"].text).to eq("1234567890123")
    end

    it "generates XML with minimal fields" do
      adres = described_class.new(
        kod_kraju: "PL",
        adres_l1: "Kraków"
      )

      doc = adres.to_rexml
      expect(doc.root.elements["KodKraju"].text).to eq("PL")
      expect(doc.root.elements["AdresL1"].text).to eq("Kraków")
      expect(doc.root.elements["AdresL2"]).to be_nil
    end
  end

  describe ".from_nokogiri" do
    it "parses XML with all fields" do
      xml = <<~XML
        <Adres>
          <KodKraju>PL</KodKraju>
          <AdresL1>Testowa 123/45</AdresL1>
          <AdresL2>00-001 Warszawa</AdresL2>
          <GLN>1234567890123</GLN>
        </Adres>
      XML

      doc = Nokogiri::XML(xml)
      adres = described_class.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.adres_l1).to eq("Testowa 123/45")
      expect(adres.adres_l2).to eq("00-001 Warszawa")
      expect(adres.gln).to eq("1234567890123")
    end

    it "handles minimal XML" do
      xml = "<Adres><KodKraju>PL</KodKraju><AdresL1>Kraków</AdresL1></Adres>"
      doc = Nokogiri::XML(xml)
      adres = described_class.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.adres_l1).to eq("Kraków")
      expect(adres.adres_l2).to be_nil
    end
  end

  describe "round-trip conversion" do
    it "preserves data through XML conversion" do
      original = described_class.new(
        kod_kraju: "PL",
        adres_l1: "Główna 10",
        adres_l2: "60-001 Poznań"
      )

      xml = original.to_rexml.to_s
      doc = Nokogiri::XML(xml)
      parsed = described_class.from_nokogiri(doc.root)

      expect(parsed.kod_kraju).to eq(original.kod_kraju)
      expect(parsed.adres_l1).to eq(original.adres_l1)
      expect(parsed.adres_l2).to eq(original.adres_l2)
    end
  end
end
