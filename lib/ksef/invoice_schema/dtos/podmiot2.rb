# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Podmiot2 - nabywca (buyer)
      class Podmiot2 < BaseDTO
        include XMLSerializable

        attr_reader :dane_identyfikacyjne, :adres, :adres_koresp, :id_vat, :numer_we_wp_ue, :dane_kontaktowe

        # @param dane_identyfikacyjne [DaneIdentyfikacyjne] Dane identyfikacyjne
        # @param adres [Adres] Adres
        # @param adres_koresp [Adres, nil] Adres korespondencyjny
        # @param id_vat [String, nil] Identyfikator VAT UE
        # @param numer_we_wp_ue [String, nil] Numer WE/WP UE
        # @param dane_kontaktowe [DaneKontaktowe, nil] Kontaktní údaje
        def initialize(
          dane_identyfikacyjne:,
          adres:,
          adres_koresp: nil,
          id_vat: nil,
          numer_we_wp_ue: nil,
          dane_kontaktowe: nil
        )
          @dane_identyfikacyjne = dane_identyfikacyjne
          @adres = adres
          @adres_koresp = adres_koresp
          @id_vat = id_vat
          @numer_we_wp_ue = numer_we_wp_ue
          @dane_kontaktowe = dane_kontaktowe
        end

        def to_rexml
          doc = REXML::Document.new
          podmiot = doc.add_element("Podmiot2")

          add_child_element(podmiot, @dane_identyfikacyjne)
          add_child_element(podmiot, @adres)
          add_child_element(podmiot, @adres_koresp) if @adres_koresp
          add_child_element(podmiot, @dane_kontaktowe) if @dane_kontaktowe
          add_element_if_present(podmiot, "IDNabywcy", @id_vat)
          add_element_if_present(podmiot, "NumerWEWPUE", @numer_we_wp_ue)

          doc
        end

        def self.from_nokogiri(element)
          new(
            dane_identyfikacyjne: object_at(element, "DaneIdentyfikacyjne", DaneIdentyfikacyjne),
            adres: object_at(element, "Adres", Adres),
            adres_koresp: object_at(element, "AdresKoresp", Adres),
            dane_kontaktowe: object_at(element, "DaneKontaktowe", DaneKontaktowe),
            id_vat: text_at(element, "IDNabywcy"),
            numer_we_wp_ue: text_at(element, "NumerWEWPUE")
          )
        end
      end
    end
  end
end
