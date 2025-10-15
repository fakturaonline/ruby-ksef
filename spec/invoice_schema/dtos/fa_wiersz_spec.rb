# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::FaWiersz do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      wiersz = described_class.new(
        nr_wiersza: 1,
        p_7: "Test Product",
        p_8a: "szt",
        p_8b: 10,
        p_9a: 100.00,
        p_9b: 1000.00,
        p_11: 23,
        p_12: 230.00
      )

      doc = wiersz.to_rexml
      expect(doc.root.name).to eq("FaWiersz")
      expect(doc.root.elements["NrWiersza"].text).to eq("1")
      expect(doc.root.elements["P_7"].text).to eq("Test Product")
      expect(doc.root.elements["P_11"].text).to eq("23")
    end

    it "formats decimal values correctly" do
      wiersz = described_class.new(
        nr_wiersza: 1,
        p_7: "Service",
        p_9b: 1234.567,
        p_11: 23,
        p_12: 284.12
      )

      doc = wiersz.to_rexml
      expect(doc.root.elements["P_9B"].text).to eq("1234.57")
      expect(doc.root.elements["P_12"].text).to eq("284.12")
    end
  end

  describe ".from_nokogiri" do
    it "parses XML with all fields" do
      xml = <<~XML
        <FaWiersz>
          <NrWiersza>1</NrWiersza>
          <P_7>Test Product</P_7>
          <P_8A>szt</P_8A>
          <P_8B>10.00</P_8B>
          <P_9A>100.00</P_9A>
          <P_9B>1000.00</P_9B>
          <P_11>23</P_11>
          <P_12>230.00</P_12>
        </FaWiersz>
      XML

      doc = Nokogiri::XML(xml)
      wiersz = described_class.from_nokogiri(doc.root)

      expect(wiersz.nr_wiersza).to eq(1)
      expect(wiersz.p_7).to eq("Test Product")
      expect(wiersz.p_8a).to eq("szt")
      expect(wiersz.p_8b).to eq(BigDecimal("10.00"))
      expect(wiersz.p_9b).to eq(BigDecimal("1000.00"))
      expect(wiersz.p_11).to eq(23)
      expect(wiersz.p_12).to eq(BigDecimal("230.00"))
    end

    it "handles string VAT rate" do
      xml = <<~XML
        <FaWiersz>
          <NrWiersza>1</NrWiersza>
          <P_7>Exempt Service</P_7>
          <P_9B>1000.00</P_9B>
          <P_11>zw</P_11>
          <P_12>0.00</P_12>
        </FaWiersz>
      XML

      doc = Nokogiri::XML(xml)
      wiersz = described_class.from_nokogiri(doc.root)

      expect(wiersz.p_11).to eq("zw")
    end
  end

  describe "round-trip conversion" do
    it "preserves data through XML conversion" do
      original = described_class.new(
        nr_wiersza: 5,
        p_7: "Complex Product",
        p_8a: "kg",
        p_8b: 25.5,
        p_9b: 1275.00,
        p_11: 8,
        p_12: 102.00
      )

      xml = original.to_rexml.to_s
      doc = Nokogiri::XML(xml)
      parsed = described_class.from_nokogiri(doc.root)

      expect(parsed.nr_wiersza).to eq(original.nr_wiersza)
      expect(parsed.p_7).to eq(original.p_7)
      expect(parsed.p_8a).to eq(original.p_8a)
      expect(parsed.p_11).to eq(original.p_11)
    end
  end
end
