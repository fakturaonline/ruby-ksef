# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::Parser do
  # Test via actual DTO that uses the parser
  describe "integration via Adres" do
    it "parses text fields correctly" do
      xml = "<Adres><KodKraju>PL</KodKraju><AdresL1>Testowa 1</AdresL1><AdresL2>00-001 Warszawa</AdresL2></Adres>"
      doc = Nokogiri::XML(xml)
      adres = KSEF::InvoiceSchema::DTOs::Adres.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.adres_l1).to eq("Testowa 1")
      expect(adres.adres_l2).to eq("00-001 Warszawa")
    end

    it "returns nil for missing optional fields" do
      xml = "<Adres><KodKraju>PL</KodKraju><AdresL1>Test</AdresL1></Adres>"
      doc = Nokogiri::XML(xml)
      adres = KSEF::InvoiceSchema::DTOs::Adres.from_nokogiri(doc.root)

      expect(adres.adres_l2).to be_nil
      expect(adres.gln).to be_nil
    end
  end

  describe "integration via Fa (date and decimal parsing)" do
    it "parses dates correctly" do
      xml = <<~XML
        <Fa>
          <KodWaluty>PLN</KodWaluty>
          <P_1>2025-01-15</P_1>
          <P_2>FV/001</P_2>
          <P_15>1000.00</P_15>
          <Adnotacje>
            <P_16>2</P_16>
            <P_17>2</P_17>
            <P_18>2</P_18>
            <P_18A>2</P_18A>
            <Zwolnienie><P_19N>1</P_19N></Zwolnienie>
            <NoweSrodkiTransportu><P_22N>1</P_22N></NoweSrodkiTransportu>
            <P_23>2</P_23>
            <PMarzy><P_PMarzyN>1</P_PMarzyN></PMarzy>
          </Adnotacje>
          <RodzajFaktury>VAT</RodzajFaktury>
        </Fa>
      XML

      doc = Nokogiri::XML(xml)
      fa = KSEF::InvoiceSchema::Fa.from_nokogiri(doc.root)

      expect(fa.p_1).to eq(Date.new(2025, 1, 15))
    end

    it "parses decimal amounts correctly" do
      xml = <<~XML
        <Fa>
          <KodWaluty>PLN</KodWaluty>
          <P_1>2025-01-15</P_1>
          <P_2>FV/001</P_2>
          <P_13_1>1000.50</P_13_1>
          <P_13_2>230.12</P_13_2>
          <P_15>1230.62</P_15>
          <Adnotacje>
            <P_16>2</P_16>
            <P_17>2</P_17>
            <P_18>2</P_18>
            <P_18A>2</P_18A>
            <Zwolnienie><P_19N>1</P_19N></Zwolnienie>
            <NoweSrodkiTransportu><P_22N>1</P_22N></NoweSrodkiTransportu>
            <P_23>2</P_23>
            <PMarzy><P_PMarzyN>1</P_PMarzyN></PMarzy>
          </Adnotacje>
          <RodzajFaktury>VAT</RodzajFaktury>
        </Fa>
      XML

      doc = Nokogiri::XML(xml)
      fa = KSEF::InvoiceSchema::Fa.from_nokogiri(doc.root)

      expect(fa.p_13_1).to eq(BigDecimal("1000.50"))
      expect(fa.p_13_2).to eq(BigDecimal("230.12"))
      expect(fa.p_15).to eq(BigDecimal("1230.62"))
    end
  end

  describe "integration via FaWiersz (array and integer parsing)" do
    it "parses integers correctly" do
      xml = <<~XML
        <FaWiersz>
          <NrWiersza>5</NrWiersza>
          <P_7>Test</P_7>
          <P_9B>100.00</P_9B>
          <P_11>23</P_11>
          <P_12>23.00</P_12>
        </FaWiersz>
      XML

      doc = Nokogiri::XML(xml)
      wiersz = KSEF::InvoiceSchema::DTOs::FaWiersz.from_nokogiri(doc.root)

      expect(wiersz.nr_wiersza).to eq(5)
      expect(wiersz.p_11).to eq(23)
    end
  end

  describe "integration via Naglowek (time parsing)" do
    it "parses timestamps correctly" do
      xml = <<~XML
        <Naglowek>
          <KodFormularza kodSystemowy='FA(2)' wersjaSchemy='1-0E'>FA</KodFormularza>
          <WariantFormularza>2</WariantFormularza>
          <DataWytworzeniaFa>2025-01-15T12:30:00Z</DataWytworzeniaFa>
        </Naglowek>
      XML

      doc = Nokogiri::XML(xml)
      naglowek = KSEF::InvoiceSchema::Naglowek.from_nokogiri(doc.root)

      expect(naglowek.data_wytworzenia_fa).to be_a(Time)
    end
  end

  describe "integration via complete invoice (array parsing)" do
    it "parses arrays of line items" do
      xml = <<~XML
        <Faktura>
          <Naglowek>
            <KodFormularza kodSystemowy='FA(2)' wersjaSchemy='1-0E'>FA</KodFormularza>
            <WariantFormularza>2</WariantFormularza>
            <DataWytworzeniaFa>2025-01-15T10:00:00Z</DataWytworzeniaFa>
          </Naglowek>
          <Podmiot1>
            <DaneIdentyfikacyjne><NIP>1234567890</NIP><Nazwa>Test</Nazwa></DaneIdentyfikacyjne>
            <Adres><KodKraju>PL</KodKraju><AdresL1>W-wa</AdresL1></Adres>
          </Podmiot1>
          <Podmiot2>
            <DaneIdentyfikacyjne><NIP>9876543210</NIP><Nazwa>Buyer</Nazwa></DaneIdentyfikacyjne>
            <Adres><KodKraju>PL</KodKraju><AdresL1>Krakow</AdresL1></Adres>
            <JSTOznaczenie>2</JSTOznaczenie>
            <GVOznaczenie>2</GVOznaczenie>
          </Podmiot2>
          <Fa>
            <KodWaluty>PLN</KodWaluty>
            <P_1>2025-01-15</P_1>
            <P_2>FV/001</P_2>
            <P_15>1000.00</P_15>
            <Adnotacje>
              <P_16>2</P_16>
              <P_17>2</P_17>
              <P_18>2</P_18>
              <P_18A>2</P_18A>
              <Zwolnienie><P_19N>1</P_19N></Zwolnienie>
              <NoweSrodkiTransportu><P_22N>1</P_22N></NoweSrodkiTransportu>
              <P_23>2</P_23>
              <PMarzy><P_PMarzyN>1</P_PMarzyN></PMarzy>
            </Adnotacje>
            <RodzajFaktury>VAT</RodzajFaktury>
            <FaWiersz><NrWierszaFa>1</NrWierszaFa><P_7>A</P_7><P_9B>100.00</P_9B><P_11>23.00</P_11><P_12>23</P_12></FaWiersz>
            <FaWiersz><NrWierszaFa>2</NrWierszaFa><P_7>B</P_7><P_9B>200.00</P_9B><P_11>46.00</P_11><P_12>23</P_12></FaWiersz>
            <FaWiersz><NrWierszaFa>3</NrWierszaFa><P_7>C</P_7><P_9B>300.00</P_9B><P_11>69.00</P_11><P_12>23</P_12></FaWiersz>
          </Fa>
        </Faktura>
      XML

      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!
      faktura = KSEF::InvoiceSchema::Faktura.from_nokogiri(doc)

      expect(faktura.fa.fa_wiersz.size).to eq(3)
      expect(faktura.fa.fa_wiersz.map(&:p_7)).to eq(%w[A B C])
    end
  end
end
# rubocop:enable Naming/VariableNumber
