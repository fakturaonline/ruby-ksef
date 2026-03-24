# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::Faktura, ".from_xml" do
  let(:seller) do
    KSEF::InvoiceSchema::DTOs::Podmiot1.new(
      dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
        nip: "1234567890",
        nazwa: "Test Company"
      ),
      adres: KSEF::InvoiceSchema::DTOs::Adres.new(
        kod_kraju: "PL",
        adres_l1: "Testowa 1",
        adres_l2: "00-001 Warszawa"
      )
    )
  end

  let(:buyer) do
    KSEF::InvoiceSchema::DTOs::Podmiot2.new(
      dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
        nip: "9876543210",
        nazwa: "Customer Ltd."
      ),
      adres: KSEF::InvoiceSchema::DTOs::Adres.new(
        kod_kraju: "PL",
        adres_l1: "Główna 5",
        adres_l2: "30-001 Kraków"
      ),
      jst: 2,  # není jednotka podřízená JST
      gv: 2    # není člen skupiny VAT
    )
  end

  let(:lines) do
    [
      KSEF::InvoiceSchema::DTOs::FaWiersz.new(
        nr_wiersza: 1,
        p_7: "Test Service",
        p_9b: 1000.00,
        p_11: 230.00,  # FA(3): P_11 = netto amount
        p_12: 23       # FA(3): P_12 = stawka VAT
      )
    ]
  end

  let(:invoice) do
    described_class.new(
      naglowek: KSEF::InvoiceSchema::Naglowek.new(system_info: "Test System"),
      podmiot1: seller,
      podmiot2: buyer,
      fa: KSEF::InvoiceSchema::Fa.new(
        kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
        p_1: Date.new(2025, 1, 15),
        p_2: "FV/2025/001",
        p_15: 1230.00,
        fa_wiersz: lines,
        p_13_1: 1000.00,
        p_13_2: 230.00
      )
    )
  end

  describe "round-trip conversion" do
    it "converts to XML and back without data loss" do
      xml = invoice.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.fa.p_2).to eq(invoice.fa.p_2)
      expect(parsed.fa.p_1).to eq(invoice.fa.p_1)
      expect(parsed.fa.p_15).to eq(invoice.fa.p_15)
      expect(parsed.fa.kod_waluty.to_s).to eq(invoice.fa.kod_waluty.to_s)
    end

    it "preserves seller data" do
      xml = invoice.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.podmiot1.dane_identyfikacyjne.nip).to eq("1234567890")
      expect(parsed.podmiot1.dane_identyfikacyjne.nazwa).to eq("Test Company")
      expect(parsed.podmiot1.adres.adres_l1).to eq("Testowa 1")
      expect(parsed.podmiot1.adres.adres_l2).to eq("00-001 Warszawa")
    end

    it "preserves buyer data" do
      xml = invoice.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.podmiot2.dane_identyfikacyjne.nip).to eq("9876543210")
      expect(parsed.podmiot2.dane_identyfikacyjne.nazwa).to eq("Customer Ltd.")
      expect(parsed.podmiot2.adres.adres_l1).to eq("Główna 5")
      expect(parsed.podmiot2.adres.adres_l2).to eq("30-001 Kraków")
    end

    it "preserves line items" do
      xml = invoice.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.fa.fa_wiersz.size).to eq(1)
      expect(parsed.fa.fa_wiersz.first.p_7).to eq("Test Service")
      expect(parsed.fa.fa_wiersz.first.p_9b).to eq(BigDecimal("1000.00"))
      expect(parsed.fa.fa_wiersz.first.p_11).to eq(BigDecimal("230.00")) # FA(3): P_11 = netto amount
    end

    it "handles multiple round-trips" do
      xml1 = invoice.to_xml
      parsed1 = described_class.from_xml(xml1)
      xml2 = parsed1.to_xml
      parsed2 = described_class.from_xml(xml2)

      expect(parsed2.fa.p_2).to eq(invoice.fa.p_2)
      expect(parsed2.fa.p_15).to eq(invoice.fa.p_15)
    end
  end

  describe "parsing real KSEF XML" do
    let(:ksef_xml) do
      <<~XML
        <?xml version='1.0' encoding='UTF-8'?>
        <Faktura xmlns='http://crd.gov.pl/wzor/2023/06/29/12648/'>
          <Naglowek>
            <KodFormularza kodSystemowy='FA(2)' wersjaSchemy='1-0E'>FA</KodFormularza>
            <WariantFormularza>2</WariantFormularza>
            <DataWytworzeniaFa>2025-01-15T10:30:00Z</DataWytworzeniaFa>
            <SystemInfo>Parser Test</SystemInfo>
          </Naglowek>
          <Podmiot1>
            <DaneIdentyfikacyjne>
              <NIP>1234567890</NIP>
              <Nazwa>Seller Corp</Nazwa>
            </DaneIdentyfikacyjne>
            <Adres>
              <KodKraju>PL</KodKraju>
              <Miejscowosc>Warszawa</Miejscowosc>
              <KodPocztowy>00-001</KodPocztowy>
            </Adres>
          </Podmiot1>
          <Podmiot2>
            <DaneIdentyfikacyjne>
              <NIP>9876543210</NIP>
              <Nazwa>Buyer Inc</Nazwa>
            </DaneIdentyfikacyjne>
            <Adres>
              <KodKraju>PL</KodKraju>
              <Miejscowosc>Kraków</Miejscowosc>
            </Adres>
          </Podmiot2>
          <Fa>
            <KodWaluty>PLN</KodWaluty>
            <P_1>2025-01-15</P_1>
            <P_2>FV/2025/999</P_2>
            <P_13_1>5000.00</P_13_1>
            <P_13_2>1150.00</P_13_2>
            <P_15>6150.00</P_15>
            <Adnotacje/>
            <RodzajFaktury>VAT</RodzajFaktury>
            <FaWiersz>
              <NrWiersza>1</NrWiersza>
              <P_7>Product A</P_7>
              <P_8B>10.00</P_8B>
              <P_9B>5000.00</P_9B>
              <P_11>23</P_11>
              <P_12>1150.00</P_12>
            </FaWiersz>
          </Fa>
        </Faktura>
      XML
    end

    xit "parses complete KSEF XML" do
      # PENDING: Needs FA(3) format XML with required Podmiot2 fields (jst, gv)
      # and Adnotacje with complete structure
      parsed = described_class.from_xml(ksef_xml)

      expect(parsed.fa.p_2).to eq("FV/2025/999")
      expect(parsed.fa.p_15).to eq(BigDecimal("6150.00"))
      expect(parsed.podmiot1.dane_identyfikacyjne.nazwa).to eq("Seller Corp")
      expect(parsed.podmiot2.dane_identyfikacyjne.nazwa).to eq("Buyer Inc")
    end

    xit "parses line items correctly" do
      # PENDING: Needs FA(3) format XML with NrWierszaFa and correct P_11/P_12 semantics
      parsed = described_class.from_xml(ksef_xml)

      expect(parsed.fa.fa_wiersz.size).to eq(1)
      line = parsed.fa.fa_wiersz.first
      expect(line.p_7).to eq("Product A")
      expect(line.p_8b).to eq(BigDecimal("10.00"))
      expect(line.p_9b).to eq(BigDecimal("5000.00"))
      expect(line.p_11).to eq(23)
    end
  end
end
# rubocop:enable Naming/VariableNumber
