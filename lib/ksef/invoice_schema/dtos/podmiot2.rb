# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Podmiot2 - nabywca (buyer)
      class Podmiot2 < BaseDTO
        include XMLSerializable

        attr_reader :dane_identyfikacyjne, :adres, :adres_koresp, :id_vat, :numer_we_wp_ue

        # @param dane_identyfikacyjne [DaneIdentyfikacyjne] Dane identyfikacyjne
        # @param adres [Adres] Adres
        # @param adres_koresp [Adres, nil] Adres korespondencyjny
        # @param id_vat [String, nil] Identyfikator VAT UE
        # @param numer_we_wp_ue [String, nil] Numer WE/WP UE
        def initialize(
          dane_identyfikacyjne:,
          adres:,
          adres_koresp: nil,
          id_vat: nil,
          numer_we_wp_ue: nil
        )
          @dane_identyfikacyjne = dane_identyfikacyjne
          @adres = adres
          @adres_koresp = adres_koresp
          @id_vat = id_vat
          @numer_we_wp_ue = numer_we_wp_ue
        end

        def to_rexml
          doc = REXML::Document.new
          podmiot = doc.add_element('Podmiot2')

          add_child_element(podmiot, @dane_identyfikacyjne)
          add_child_element(podmiot, @adres)
          add_child_element(podmiot, @adres_koresp) if @adres_koresp
          add_element_if_present(podmiot, 'IDNabywcy', @id_vat)
          add_element_if_present(podmiot, 'NumerWEWPUE', @numer_we_wp_ue)

          doc
        end
      end
    end
  end
end
