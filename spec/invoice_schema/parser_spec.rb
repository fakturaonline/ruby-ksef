# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::Parser do
  # Test via actual DTO that uses the parser
  describe "integration via Adres" do
    it "parses text fields correctly" do
      xml = "<Adres><KodKraju>PL</KodKraju><Miejscowosc>Warszawa</Miejscowosc></Adres>"
      doc = Nokogiri::XML(xml)
      adres = KSEF::InvoiceSchema::DTOs::Adres.from_nokogiri(doc.root)

      expect(adres.kod_kraju).to eq("PL")
      expect(adres.miejscowosc).to eq("Warszawa")
    end

    it "returns nil for missing optional fields" do
      xml = "<Adres><KodKraju>PL</KodKraju><Miejscowosc>Test</Miejscowosc></Adres>"
      doc = Nokogiri::XML(xml)
      adres = KSEF::InvoiceSchema::DTOs::Adres.from_nokogiri(doc.root)

      expect(adres.ulica).to be_nil
      expect(adres.nr_domu).to be_nil
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
          <Adnotacje/>
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
          <Adnotacje/>
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
            <Adres><KodKraju>PL</KodKraju><Miejscowosc>W-wa</Miejscowosc></Adres>
          </Podmiot1>
          <Podmiot2>
            <DaneIdentyfikacyjne><NIP>9876543210</NIP><Nazwa>Buyer</Nazwa></DaneIdentyfikacyjne>
            <Adres><KodKraju>PL</KodKraju><Miejscowosc>Krakow</Miejscowosc></Adres>
          </Podmiot2>
          <Fa>
            <KodWaluty>PLN</KodWaluty>
            <P_1>2025-01-15</P_1>
            <P_2>FV/001</P_2>
            <P_15>1000.00</P_15>
            <Adnotacje/>
            <RodzajFaktury>VAT</RodzajFaktury>
            <FaWiersz><NrWiersza>1</NrWiersza><P_7>A</P_7><P_9B>100.00</P_9B><P_11>23</P_11><P_12>23.00</P_12></FaWiersz>
            <FaWiersz><NrWiersza>2</NrWiersza><P_7>B</P_7><P_9B>200.00</P_9B><P_11>23</P_11><P_12>46.00</P_12></FaWiersz>
            <FaWiersz><NrWiersza>3</NrWiersza><P_7>C</P_7><P_9B>300.00</P_9B><P_11>23</P_11><P_12>69.00</P_12></FaWiersz>
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
