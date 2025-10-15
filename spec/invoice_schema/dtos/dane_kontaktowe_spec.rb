# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::DaneKontaktowe do
  describe "#to_rexml" do
    it "generates XML with email and phone" do
      kontakt = described_class.new(
        email: "test@example.com",
        telefon: "+48 123 456 789"
      )

      xml = kontakt.to_rexml.to_s

      expect(xml).to include("<Email>test@example.com</Email>")
      expect(xml).to include("<Telefon>+48 123 456 789</Telefon>")
    end

    it "generates XML with only email" do
      kontakt = described_class.new(email: "test@example.com")

      xml = kontakt.to_rexml.to_s

      expect(xml).to include("<Email>test@example.com</Email>")
      expect(xml).not_to include("<Telefon>")
    end

    it "generates XML with only phone" do
      kontakt = described_class.new(telefon: "+48 123 456 789")

      xml = kontakt.to_rexml.to_s

      expect(xml).to include("<Telefon>+48 123 456 789</Telefon>")
      expect(xml).not_to include("<Email>")
    end
  end
end
