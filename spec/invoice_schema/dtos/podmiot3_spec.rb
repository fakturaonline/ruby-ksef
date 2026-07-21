# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Podmiot3 do
  let(:dane_identyfikacyjne) do
    KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
      brak_id: 1,
      nazwa: "Szkola Podstawowa nr 1"
    )
  end

  let(:adres) do
    KSEF::InvoiceSchema::DTOs::Adres.new(
      kod_kraju: "PL",
      adres_l1: "Szkolna 1",
      adres_l2: "00-001 Warszawa"
    )
  end

  describe "#initialize" do
    it "creates a JST odbiorca (rola 8) without NIP" do
      podmiot = described_class.new(
        dane_identyfikacyjne: dane_identyfikacyjne,
        adres: adres,
        rola: 8
      )

      expect(podmiot.rola).to eq(8)
      expect(podmiot.dane_identyfikacyjne.brak_id).to eq(1)
    end

    it "accepts identification via NIP" do
      podmiot = described_class.new(
        dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
          nip: "1234567890",
          nazwa: "Jednostka z NIP"
        ),
        rola: 8
      )

      expect(podmiot.dane_identyfikacyjne.nip).to eq("1234567890")
    end

    it "requires dane_identyfikacyjne" do
      expect do
        described_class.new(dane_identyfikacyjne: nil, rola: 8)
      end.to raise_error(ArgumentError, /dane_identyfikacyjne is required/)
    end

    it "requires rola within TRolaPodmiotu3 range" do
      expect do
        described_class.new(dane_identyfikacyjne: dane_identyfikacyjne, rola: 12)
      end.to raise_error(ArgumentError, /rola is required/)

      expect do
        described_class.new(dane_identyfikacyjne: dane_identyfikacyjne, rola: nil)
      end.to raise_error(ArgumentError, /rola is required/)
    end

    it "limits id_nabywcy to 32 characters" do
      expect do
        described_class.new(
          dane_identyfikacyjne: dane_identyfikacyjne,
          rola: 8,
          id_nabywcy: "x" * 33
        )
      end.to raise_error(ArgumentError, /id_nabywcy/)
    end

    it "limits dane_kontaktowe to 3 items" do
      kontakt = KSEF::InvoiceSchema::DTOs::DaneKontaktowe.new(email: "test@example.com")

      expect do
        described_class.new(
          dane_identyfikacyjne: dane_identyfikacyjne,
          rola: 8,
          dane_kontaktowe: [kontakt, kontakt, kontakt, kontakt]
        )
      end.to raise_error(ArgumentError, /dane_kontaktowe/)
    end
  end

  describe "#to_rexml" do
    it "serializes elements in XSD order" do
      podmiot = described_class.new(
        dane_identyfikacyjne: dane_identyfikacyjne,
        adres: adres,
        rola: 8,
        nr_klienta: "KLIENT-1"
      )

      xml = String.new
      REXML::Formatters::Default.new.write(podmiot.to_rexml, xml)

      expect(xml).to include("<Podmiot3>")
      expect(xml).to include("<BrakID>1</BrakID>")
      expect(xml).to include("<Nazwa>Szkola Podstawowa nr 1</Nazwa>")
      expect(xml).to include("<Rola>8</Rola>")
      expect(xml).to include("<NrKlienta>KLIENT-1</NrKlienta>")
      # Rola must come after DaneIdentyfikacyjne/Adres and before NrKlienta
      expect(xml.index("<DaneIdentyfikacyjne>")).to be < xml.index("<Adres>")
      expect(xml.index("<Adres>")).to be < xml.index("<Rola>")
      expect(xml.index("<Rola>")).to be < xml.index("<NrKlienta>")
    end
  end

  describe ".from_nokogiri" do
    it "round-trips through XML" do
      original = described_class.new(
        dane_identyfikacyjne: dane_identyfikacyjne,
        adres: adres,
        rola: 8
      )

      xml = String.new
      REXML::Formatters::Default.new.write(original.to_rexml, xml)
      parsed = described_class.from_nokogiri(Nokogiri::XML(xml).root)

      expect(parsed.rola).to eq(8)
      expect(parsed.dane_identyfikacyjne.brak_id).to eq(1)
      expect(parsed.dane_identyfikacyjne.nazwa).to eq("Szkola Podstawowa nr 1")
      expect(parsed.adres.adres_l1).to eq("Szkolna 1")
    end
  end
end
