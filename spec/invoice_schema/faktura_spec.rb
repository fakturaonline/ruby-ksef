# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::Faktura do
  let(:naglowek) do
    KSEF::InvoiceSchema::Naglowek.new(
      system_info: "Test System"
    )
  end

  let(:dane_prodejce) do
    KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
      nip: "1234567890",
      nazwa: "Test Firma"
    )
  end

  let(:adres_prodejce) do
    KSEF::InvoiceSchema::DTOs::Adres.new(
      kod_kraju: "PL",
      adres_l1: "Testowa 1",
      adres_l2: "00-001 Warszawa"
    )
  end

  let(:podmiot1) do
    KSEF::InvoiceSchema::DTOs::Podmiot1.new(
      dane_identyfikacyjne: dane_prodejce,
      adres: adres_prodejce
    )
  end

  let(:dane_kupujici) do
    KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
      nip: "9876543210",
      nazwa: "Test Klient"
    )
  end

  let(:adres_kupujici) do
    KSEF::InvoiceSchema::DTOs::Adres.new(
      kod_kraju: "PL",
      adres_l1: "Klienta 5",
      adres_l2: "30-001 Kraków"
    )
  end

  let(:podmiot2) do
    KSEF::InvoiceSchema::DTOs::Podmiot2.new(
      dane_identyfikacyjne: dane_kupujici,
      adres: adres_kupujici,
      jst: 2,  # není jednotka podřízená JST
      gv: 2    # není člen skupiny VAT
    )
  end

  let(:fa_wiersz) do
    KSEF::InvoiceSchema::DTOs::FaWiersz.new(
      nr_wiersza: 1,
      p_7: "Test Service",
      p_9b: 1000.00,
      p_11: 23,
      p_12: 230.00
    )
  end

  let(:fa) do
    KSEF::InvoiceSchema::Fa.new(
      kod_waluty: "PLN",
      p_1: Date.new(2024, 1, 15),
      p_2: "FV/TEST/001",
      p_15: 1230.00,
      fa_wiersz: [fa_wiersz],
      p_13_1: 1000.00,
      p_13_2: 230.00
    )
  end

  let(:faktura) do
    described_class.new(
      naglowek: naglowek,
      podmiot1: podmiot1,
      podmiot2: podmiot2,
      fa: fa
    )
  end

  describe "#to_xml" do
    it "generates valid XML" do
      xml = faktura.to_xml

      expect(xml).to be_a(String)
      expect(xml).to include("<?xml version")
      expect(xml).to include("<Faktura")
      expect(xml).to include("xmlns=")
    end

    it "includes all main sections" do
      xml = faktura.to_xml

      expect(xml).to include("<Naglowek>")
      expect(xml).to include("<Podmiot1>")
      expect(xml).to include("<Podmiot2>")
      expect(xml).to include("<Fa>")
    end

    it "includes invoice data" do
      xml = faktura.to_xml

      expect(xml).to include("FV/TEST/001")
      expect(xml).to include("PLN")
      expect(xml).to include("1230.00")
      expect(xml).to include("Test Firma")
      expect(xml).to include("Test Klient")
    end

    it "includes invoice line items" do
      xml = faktura.to_xml

      expect(xml).to include("<FaWiersz>")
      expect(xml).to include("Test Service")
      expect(xml).to include("1000.00")
      expect(xml).to include("230.00")
    end
  end

  describe "#to_rexml" do
    it "returns REXML::Document" do
      doc = faktura.to_rexml

      expect(doc).to be_a(REXML::Document)
    end

    it "has root element Faktura" do
      doc = faktura.to_rexml

      expect(doc.root.name).to eq("Faktura")
    end

    it "has proper namespaces" do
      doc = faktura.to_rexml
      root = doc.root

      expect(root.namespace).to include("crd.gov.pl")
      expect(root.namespaces["xsi"]).to include("XMLSchema-instance")
      expect(root.namespaces["etd"]).to include("DefinicjeTypy")
    end
  end

  describe "with podmiot3" do
    let(:podmiot3) do
      KSEF::InvoiceSchema::DTOs::Podmiot3.new(
        dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
          brak_id: 1,
          nazwa: "Szkola Podstawowa nr 1"
        ),
        adres: KSEF::InvoiceSchema::DTOs::Adres.new(
          kod_kraju: "PL",
          adres_l1: "Szkolna 1",
          adres_l2: "00-001 Warszawa"
        ),
        rola: 8
      )
    end

    let(:faktura_jst) do
      described_class.new(
        naglowek: naglowek,
        podmiot1: podmiot1,
        podmiot2: podmiot2,
        podmiot3: podmiot3,
        fa: fa
      )
    end

    it "serializes Podmiot3 between Podmiot2 and Fa" do
      xml = faktura_jst.to_xml

      expect(xml).to include("<Podmiot3>")
      expect(xml).to include("<Rola>8</Rola>")
      expect(xml.index("<Podmiot2>")).to be < xml.index("<Podmiot3>")
      expect(xml.index("<Podmiot3>")).to be < xml.index("<Fa>")
    end

    it "omits Podmiot3 when not provided" do
      expect(faktura.to_xml).not_to include("<Podmiot3>")
    end

    it "round-trips podmiot3 through from_xml" do
      parsed = described_class.from_xml(faktura_jst.to_xml)

      expect(parsed.podmiot3).not_to be_nil
      expect(parsed.podmiot3.rola).to eq(8)
      expect(parsed.podmiot3.dane_identyfikacyjne.nazwa).to eq("Szkola Podstawowa nr 1")
    end
  end
end
