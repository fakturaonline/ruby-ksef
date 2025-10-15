# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::FaWiersz do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      wiersz = described_class.new(
        nr_wiersza: 1,
        p_7: "Test Service",
        p_8a: "ks",
        p_8b: 10,
        p_9a: 100.00,
        p_9b: 1000.00,
        p_11: 23,
        p_11a: "TP",
        p_12: 230.00,
        cena_jednostkowa: 123.00,
        wartosc_pozycji_smr: 1230.00
      )

      xml = wiersz.to_rexml.to_s

      expect(xml).to include("<NrWiersza>1</NrWiersza>")
      expect(xml).to include("<P_7>Test Service</P_7>")
      expect(xml).to include("<P_8A>ks</P_8A>")
      expect(xml).to include("<P_8B>10.00</P_8B>")
      expect(xml).to include("<P_9A>100.00</P_9A>")
      expect(xml).to include("<P_9B>1000.00</P_9B>")
      expect(xml).to include("<P_11>23</P_11>")
      expect(xml).to include("<P_11A>TP</P_11A>")
      expect(xml).to include("<P_12>230.00</P_12>")
      expect(xml).to include("<CenaJednostkowa>123.00</CenaJednostkowa>")
      expect(xml).to include("<WartoscPozycjiSMR>1230.00</WartoscPozycjiSMR>")
    end

    it "generates XML with only required fields" do
      wiersz = described_class.new(
        nr_wiersza: 1,
        p_7: "Service",
        p_9b: 1000.00,
        p_11: 23,
        p_12: 230.00
      )

      xml = wiersz.to_rexml.to_s

      expect(xml).to include("<NrWiersza>1</NrWiersza>")
      expect(xml).to include("<P_7>Service</P_7>")
      expect(xml).to include("<P_9B>1000.00</P_9B>")
      expect(xml).not_to include("<P_8A>")
      expect(xml).not_to include("<P_8B>")
    end

    it "formats decimals correctly" do
      wiersz = described_class.new(
        nr_wiersza: 1,
        p_7: "Service",
        p_9b: 1234.5,
        p_11: 23,
        p_12: 283.94
      )

      xml = wiersz.to_rexml.to_s

      expect(xml).to include("<P_9B>1234.50</P_9B>")
      expect(xml).to include("<P_12>283.94</P_12>")
    end
  end
end
