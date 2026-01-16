# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Podmiot1 - sprzedawca (seller) - FA(3) format
      #
      # Structure:
      # - PrefiksPodatnika (optional, fixed="PL")
      # - NrEORI (optional)
      # - DaneIdentyfikacyjne (required, type=TPodmiot1)
      # - Adres (required, type=TAdres)
      # - AdresKoresp (optional)
      # - DaneKontaktowe (optional, max 3)
      # - StatusInfoPodatnika (optional)
      class Podmiot1 < BaseDTO
        include XMLSerializable

        attr_reader :dane_identyfikacyjne, :adres, :prefiks_podatnika, :nr_eori,
                    :adres_koresp, :dane_kontaktowe, :status_info_podatnika

        # @param dane_identyfikacyjne [DaneIdentyfikacyjne] Dane identyfikacyjne (required)
        # @param adres [Adres] Adres (required)
        # @param prefiks_podatnika [String, nil] Prefiks podatnika VAT UE (usually "PL")
        # @param nr_eori [String, nil] Numer EORI podatnika
        # @param adres_koresp [Adres, nil] Adres korespondencyjny
        # @param dane_kontaktowe [Array<DaneKontaktowe>, DaneKontaktowe, nil] Dane kontaktowe (max 3)
        # @param status_info_podatnika [String, nil] Status podatnika
        def initialize(
          dane_identyfikacyjne:,
          adres:,
          prefiks_podatnika: nil,
          nr_eori: nil,
          adres_koresp: nil,
          dane_kontaktowe: nil,
          status_info_podatnika: nil
        )
          @dane_identyfikacyjne = dane_identyfikacyjne
          @adres = adres
          @prefiks_podatnika = prefiks_podatnika
          @nr_eori = nr_eori
          @adres_koresp = adres_koresp
          @dane_kontaktowe = Array(dane_kontaktowe).compact if dane_kontaktowe
          @status_info_podatnika = status_info_podatnika

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          podmiot = doc.add_element("Podmiot1")

          # 1. PrefiksPodatnika (optional)
          add_element_if_present(podmiot, "PrefiksPodatnika", @prefiks_podatnika) if @prefiks_podatnika

          # 2. NrEORI (optional)
          add_element_if_present(podmiot, "NrEORI", @nr_eori) if @nr_eori

          # 3. DaneIdentyfikacyjne (required)
          add_child_element(podmiot, @dane_identyfikacyjne)

          # 4. Adres (required)
          add_child_element(podmiot, @adres)

          # 5. AdresKoresp (optional)
          add_child_element(podmiot, @adres_koresp) if @adres_koresp

          # 6. DaneKontaktowe (optional, max 3)
          if @dane_kontaktowe
            @dane_kontaktowe.first(3).each do |dk|
              add_child_element(podmiot, dk)
            end
          end

          # 7. StatusInfoPodatnika (optional)
          add_element_if_present(podmiot, "StatusInfoPodatnika", @status_info_podatnika) if @status_info_podatnika

          doc
        end

        def self.from_nokogiri(element)
          dane_kontaktowe_elements = element.xpath("DaneKontaktowe").map do |dk_el|
            DaneKontaktowe.from_nokogiri(dk_el)
          end

          new(
            prefiks_podatnika: text_at(element, "PrefiksPodatnika"),
            nr_eori: text_at(element, "NrEORI"),
            dane_identyfikacyjne: object_at(element, "DaneIdentyfikacyjne", DaneIdentyfikacyjne),
            adres: object_at(element, "Adres", Adres),
            adres_koresp: object_at(element, "AdresKoresp", Adres),
            dane_kontaktowe: dane_kontaktowe_elements.empty? ? nil : dane_kontaktowe_elements,
            status_info_podatnika: text_at(element, "StatusInfoPodatnika")
          )
        end

        private

        def validate!
          raise ArgumentError, "dane_identyfikacyjne is required" unless @dane_identyfikacyjne
          raise ArgumentError, "adres is required" unless @adres
          raise ArgumentError, "dane_kontaktowe can have max 3 items" if @dane_kontaktowe && @dane_kontaktowe.length > 3
        end
      end
    end
  end
end
