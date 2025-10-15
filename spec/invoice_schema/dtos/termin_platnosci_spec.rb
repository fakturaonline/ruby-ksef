# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::TerminPlatnosci do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      termin = described_class.new(
        termin: Date.new(2024, 2, 15),
        forma_platnosci: "6",
        suma_platnosci: 1230.00
      )

      xml = termin.to_rexml.to_s

      expect(xml).to include("<Termin>2024-02-15</Termin>")
      expect(xml).to include("<FormaPlatnosci>6</FormaPlatnosci>")
      expect(xml).to include("<SumaPlatnosci>1230.00</SumaPlatnosci>")
    end

    it "generates XML with only required fields" do
      termin = described_class.new(termin: Date.new(2024, 2, 15))

      xml = termin.to_rexml.to_s

      expect(xml).to include("<Termin>2024-02-15</Termin>")
      expect(xml).not_to include("<FormaPlatnosci>")
      expect(xml).not_to include("<SumaPlatnosci>")
    end

    it "accepts date as string" do
      termin = described_class.new(termin: "2024-02-15")

      xml = termin.to_rexml.to_s

      expect(xml).to include("<Termin>2024-02-15</Termin>")
    end
  end
end
