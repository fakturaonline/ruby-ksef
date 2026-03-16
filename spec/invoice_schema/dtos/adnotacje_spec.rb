# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::Adnotacje do
  describe "#to_rexml" do
    it "generates XML with all fields" do
      adnotacje = described_class.new(
        p_16: 1,        # Metoda kasowa=ano
        p_17: 1,        # Samofakturowanie=ano
        p_18: 1,        # Odwrotné obciążení=ano
        p_18a: 1,       # Split payment=ano
        p_19n: 1,       # Není zwolnienie
        p_22n: 1,       # Nejsou nová vozidla
        p_23: 1,        # Procedura uproszczona=ano
        p_pmarzy_n: 1   # Není marže
      )

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<P_16>1</P_16>")
      expect(xml).to include("<P_17>1</P_17>")
      expect(xml).to include("<P_18>1</P_18>")
      expect(xml).to include("<P_18A>1</P_18A>")
      expect(xml).to include("<Zwolnienie>")
      expect(xml).to include("<P_19N>1</P_19N>")
      expect(xml).to include("<NoweSrodkiTransportu>")
      expect(xml).to include("<P_22N>1</P_22N>")
      expect(xml).to include("<P_23>1</P_23>")
      expect(xml).to include("<PMarzy>")
      expect(xml).to include("<P_PMarzyN>1</P_PMarzyN>")
    end

    it "generates empty XML when no fields set" do
      adnotacje = described_class.new

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<Adnotacje")
      # FA(3) VŽDY obsahuje všechny elementy
      expect(xml).to include("<P_16>2</P_16>")
      expect(xml).to include("<P_17>2</P_17>")
    end

    it "generates correct PMarzy XML for art. 120 margin (p_pmarzy_t)" do
      adnotacje = described_class.new(p_pmarzy_t: 1)

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<PMarzy>")
      expect(xml).to include("<P_PMarzy>1</P_PMarzy>")
      expect(xml).to include("<P_PMarzy_3_1>1</P_PMarzy_3_1>")
      expect(xml).not_to include("P_PMarzyT")
      expect(xml).not_to include("P_PMarzyN")
    end

    it "generates correct PMarzy XML for art. 119 travel agency margin (p_pmarzy_m)" do
      adnotacje = described_class.new(p_pmarzy_m: 1)

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<PMarzy>")
      expect(xml).to include("<P_PMarzy>1</P_PMarzy>")
      expect(xml).to include("<P_PMarzy_2>1</P_PMarzy_2>")
      expect(xml).not_to include("P_PMarzyM")
      expect(xml).not_to include("P_PMarzyN")
    end

    it "does not include false boolean fields" do
      adnotacje = described_class.new(
        p_16: 2,   # Ne
        p_17: 2    # Ne
      )

      xml = adnotacje.to_rexml.to_s

      expect(xml).to include("<P_16>2</P_16>")
      expect(xml).to include("<P_17>2</P_17>")
    end
  end
end
