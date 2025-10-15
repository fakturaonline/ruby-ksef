# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Adnotacje do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      adnotacje = described_class.new(
        p_16: "Adnotacja 16",
        p_17: "Adnotacja 17",
        p_18: "Adnotacja 18",
        p_18a: "Adnotacja 18A",
        zwolnienie: "Art. 43",
        nowesrodkitransportu: true,
        marza: true,
        samofakturowanie: true
      )

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<P_16>Adnotacja 16</P_16>")
      expect(xml).to include("<P_17>Adnotacja 17</P_17>")
      expect(xml).to include("<P_18>Adnotacja 18</P_18>")
      expect(xml).to include("<P_18A>Adnotacja 18A</P_18A>")
      expect(xml).to include("<Zwolnienie>Art. 43</Zwolnienie>")
      expect(xml).to include("<NoweSrodkiTransportu>1</NoweSrodkiTransportu>")
      expect(xml).to include("<Marza>1</Marza>")
      expect(xml).to include("<Samofakturowanie>1</Samofakturowanie>")
    end

    it "generates empty XML when no fields set" do
      adnotacje = described_class.new

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<Adnotacje")
      expect(xml).not_to include("<P_16>")
      expect(xml).not_to include("<Marza>")
    end

    it "does not include false boolean fields" do
      adnotacje = described_class.new(
        marza: false,
        samofakturowanie: false
      )

      xml = adnotacje.to_rexml.to_s

      expect(xml).not_to include("<Marza>")
      expect(xml).not_to include("<Samofakturowanie>")
    end
  end
end
