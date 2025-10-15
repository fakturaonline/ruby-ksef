# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Adres (address)
      class Adres < BaseDTO
        include XMLSerializable

        attr_reader :kod_kraju, :wojewodztwo, :powiat, :gmina, :ulica, :nr_domu,
                    :nr_lokalu, :miejscowosc, :kod_pocztowy, :poczta

        # @param kod_kraju [String] Kod kraju (ISO 3166-1 alpha-2)
        # @param miejscowosc [String] Miejscowość
        # @param kod_pocztowy [String, nil] Kod pocztowy
        # @param ulica [String, nil] Ulica
        # @param nr_domu [String, nil] Numer domu
        # @param nr_lokalu [String, nil] Numer lokalu
        # @param poczta [String, nil] Poczta
        # @param wojewodztwo [String, nil] Województwo
        # @param powiat [String, nil] Powiat
        # @param gmina [String, nil] Gmina
        def initialize(
          kod_kraju:,
          miejscowosc:,
          kod_pocztowy: nil,
          ulica: nil,
          nr_domu: nil,
          nr_lokalu: nil,
          poczta: nil,
          wojewodztwo: nil,
          powiat: nil,
          gmina: nil
        )
          @kod_kraju = kod_kraju
          @wojewodztwo = wojewodztwo
          @powiat = powiat
          @gmina = gmina
          @ulica = ulica
          @nr_domu = nr_domu
          @nr_lokalu = nr_lokalu
          @miejscowosc = miejscowosc
          @kod_pocztowy = kod_pocztowy
          @poczta = poczta
        end

        def to_rexml
          doc = REXML::Document.new
          adres = doc.add_element("Adres")

          add_element_if_present(adres, "KodKraju", @kod_kraju)
          add_element_if_present(adres, "Wojewodztwo", @wojewodztwo)
          add_element_if_present(adres, "Powiat", @powiat)
          add_element_if_present(adres, "Gmina", @gmina)
          add_element_if_present(adres, "Ulica", @ulica)
          add_element_if_present(adres, "NrDomu", @nr_domu)
          add_element_if_present(adres, "NrLokalu", @nr_lokalu)
          add_element_if_present(adres, "Miejscowosc", @miejscowosc)
          add_element_if_present(adres, "KodPocztowy", @kod_pocztowy)
          add_element_if_present(adres, "Poczta", @poczta)

          doc
        end

        def self.from_nokogiri(element)
          new(
            kod_kraju: text_at(element, "KodKraju"),
            miejscowosc: text_at(element, "Miejscowosc"),
            kod_pocztowy: text_at(element, "KodPocztowy"),
            ulica: text_at(element, "Ulica"),
            nr_domu: text_at(element, "NrDomu"),
            nr_lokalu: text_at(element, "NrLokalu"),
            poczta: text_at(element, "Poczta"),
            wojewodztwo: text_at(element, "Wojewodztwo"),
            powiat: text_at(element, "Powiat"),
            gmina: text_at(element, "Gmina")
          )
        end
      end
    end
  end
end
