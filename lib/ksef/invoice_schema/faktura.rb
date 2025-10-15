# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Faktura - root element faktury
    class Faktura < BaseDTO
      include XMLSerializable

      attr_reader :naglowek, :podmiot1, :podmiot2, :fa, :stopka

      # @param naglowek [Naglowek] Hlavička faktury
      # @param podmiot1 [DTOs::Podmiot1] Prodejce
      # @param podmiot2 [DTOs::Podmiot2] Kupující
      # @param fa [Fa] Hlavní část faktury
      # @param stopka [DTOs::Stopka, nil] Zápatí
      def initialize(naglowek:, podmiot1:, podmiot2:, fa:, stopka: nil)
        @naglowek = naglowek
        @podmiot1 = podmiot1
        @podmiot2 = podmiot2
        @fa = fa
        @stopka = stopka
      end

      # Vrátí kompletní XML faktury jako string
      # @return [String] XML faktura
      def to_xml
        doc = to_rexml
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        output = String.new
        formatter.write(doc, output)
        output
      end

      def to_rexml
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new("1.0", "UTF-8")

        # Root element Faktura s namespaces
        faktura = doc.add_element("Faktura")
        faktura.add_namespace(@naglowek.wariant_formularza.target_namespace)
        faktura.add_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
        faktura.add_namespace("etd", "http://crd.gov.pl/xml/schematy/dziedzinowe/mf/2022/01/05/eD/DefinicjeTypy/")

        # Naglowek
        naglowek_element = @naglowek.to_rexml.root
        faktura.add_element(naglowek_element)

        # Podmiot1
        podmiot1_element = @podmiot1.to_rexml.root
        faktura.add_element(podmiot1_element)

        # Podmiot2
        podmiot2_element = @podmiot2.to_rexml.root
        faktura.add_element(podmiot2_element)

        # Fa
        fa_element = @fa.to_rexml.root
        faktura.add_element(fa_element)

        # Stopka (optional)
        if @stopka
          stopka_element = @stopka.to_rexml.root
          faktura.add_element(stopka_element)
        end

        doc
      end

      def self.from_nokogiri(doc_or_element)
        # Handle both Document and Element
        element = doc_or_element.is_a?(Nokogiri::XML::Document) ? doc_or_element.root : doc_or_element

        new(
          naglowek: Naglowek.from_nokogiri(element.at_xpath("Naglowek")),
          podmiot1: DTOs::Podmiot1.from_nokogiri(element.at_xpath("Podmiot1")),
          podmiot2: DTOs::Podmiot2.from_nokogiri(element.at_xpath("Podmiot2")),
          fa: Fa.from_nokogiri(element.at_xpath("Fa")),
          stopka: object_at(element, "Stopka", DTOs::Stopka)
        )
      end

      def self.from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!
        from_nokogiri(doc)
      end
    end
  end
end
