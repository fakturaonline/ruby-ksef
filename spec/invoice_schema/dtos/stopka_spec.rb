# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Stopka do
  describe "#to_rexml" do
    it "generates XML with single info" do
      stopka = described_class.new(
        informacje: "Faktura vystavena elektronicky"
      )

      xml = stopka.to_rexml.to_s

      expect(xml).to include("<Stopka>")
      expect(xml).to include("<Informacje>")
      expect(xml).to include("<StInformacje>Faktura vystavena elektronicky</StInformacje>")
    end

    it "generates XML with multiple infos" do
      stopka = described_class.new(
        informacje: [
          "Faktura vystavena elektronicky",
          "Vystavil: Jan Novák",
          "Děkujeme za spolupráci"
        ]
      )

      xml = stopka.to_rexml.to_s

      expect(xml.scan("<Informacje>").count).to eq(3)
      expect(xml).to include("Faktura vystavena elektronicky")
      expect(xml).to include("Vystavil: Jan Novák")
      expect(xml).to include("Děkujeme za spolupráci")
    end

    it "limits to 3 informacje" do
      stopka = described_class.new(
        informacje: ["Info 1", "Info 2", "Info 3", "Info 4", "Info 5"]
      )

      xml = stopka.to_rexml.to_s

      expect(xml.scan("<Informacje>").count).to eq(3)
    end

    it "handles empty array" do
      stopka = described_class.new(informacje: [])

      xml = stopka.to_rexml.to_s

      # Může být <Stopka/> nebo <Stopka></Stopka>
      expect(xml).to match(%r{<Stopka[\s/>]})
      expect(xml).not_to include("<Informacje>")
    end
  end
end
