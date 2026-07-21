# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Podmiot3 - third party on the invoice (other than seller/buyer) - FA(3) format
      #
      # Used e.g. for JST subordinate units (rola 8 - "Jednostka samorzadu
      # terytorialnego - odbiorca"): the receiving unit (school, kindergarten)
      # while Podmiot2 carries the gmina (JST=1).
      #
      # @example JST subordinate unit without NIP
      #   Podmiot3.new(
      #     dane_identyfikacyjne: DaneIdentyfikacyjne.new(brak_id: 1, nazwa: "Szkola Podstawowa nr 1"),
      #     adres: Adres.new(kod_kraju: "PL", adres_l1: "Szkolna 1", adres_l2: "00-001 Warszawa"),
      #     rola: 8
      #   )
      class Podmiot3 < BaseDTO
        include XMLSerializable

        # TRolaPodmiotu3 (FA(3) XSD)
        ROLA_VALUES = (1..11).to_a.freeze
        ROLA_JST_ODBIORCA = 8

        attr_reader :id_nabywcy, :nr_eori, :dane_identyfikacyjne, :adres,
                    :adres_koresp, :dane_kontaktowe, :rola, :udzial, :nr_klienta

        # @param dane_identyfikacyjne [DaneIdentyfikacyjne] Dane identyfikacyjne (required; TPodmiot3 allows BrakID)
        # @param rola [Integer] Rola podmiotu per TRolaPodmiotu3 (1..11), e.g. 8 = JST - odbiorca
        # @param id_nabywcy [String, nil] Unique buyer-link key on corrective invoices (max 32 chars)
        # @param nr_eori [String, nil] Numer EORI
        # @param adres [Adres, nil] Adres podmiotu
        # @param adres_koresp [Adres, nil] Adres korespondencyjny
        # @param dane_kontaktowe [Array<DaneKontaktowe>, DaneKontaktowe, nil] Dane kontaktowe (max 3)
        # @param udzial [String, Numeric, nil] Udzial procentowy (TProcentowy)
        # @param nr_klienta [String, nil] Numer klienta
        def initialize(
          dane_identyfikacyjne:,
          rola:,
          id_nabywcy: nil,
          nr_eori: nil,
          adres: nil,
          adres_koresp: nil,
          dane_kontaktowe: nil,
          udzial: nil,
          nr_klienta: nil
        )
          @dane_identyfikacyjne = dane_identyfikacyjne
          @rola = rola
          @id_nabywcy = id_nabywcy
          @nr_eori = nr_eori
          @adres = adres
          @adres_koresp = adres_koresp
          @dane_kontaktowe = Array(dane_kontaktowe).compact if dane_kontaktowe
          @udzial = udzial
          @nr_klienta = nr_klienta

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          podmiot = doc.add_element("Podmiot3")

          # Element order per FA(3) XSD sequence:
          # IDNabywcy?, NrEORI?, DaneIdentyfikacyjne, Adres?, AdresKoresp?,
          # DaneKontaktowe{0,3}, Rola, Udzial?, NrKlienta?

          # 1. IDNabywcy (optional)
          add_element_if_present(podmiot, "IDNabywcy", @id_nabywcy) if @id_nabywcy

          # 2. NrEORI (optional)
          add_element_if_present(podmiot, "NrEORI", @nr_eori) if @nr_eori

          # 3. DaneIdentyfikacyjne (required)
          add_child_element(podmiot, @dane_identyfikacyjne)

          # 4. Adres (optional)
          add_child_element(podmiot, @adres) if @adres

          # 5. AdresKoresp (optional)
          add_child_element(podmiot, @adres_koresp) if @adres_koresp

          # 6. DaneKontaktowe (optional, max 3)
          @dane_kontaktowe&.first(3)&.each do |dk|
            add_child_element(podmiot, dk)
          end

          # 7. Rola (required)
          add_element_if_present(podmiot, "Rola", @rola)

          # 8. Udzial (optional)
          add_element_if_present(podmiot, "Udzial", @udzial) if @udzial

          # 9. NrKlienta (optional)
          add_element_if_present(podmiot, "NrKlienta", @nr_klienta) if @nr_klienta

          doc
        end

        def self.from_nokogiri(element)
          dane_kontaktowe_elements = element.xpath("DaneKontaktowe").map do |dk_el|
            DaneKontaktowe.from_nokogiri(dk_el)
          end

          new(
            id_nabywcy: text_at(element, "IDNabywcy"),
            nr_eori: text_at(element, "NrEORI"),
            dane_identyfikacyjne: object_at(element, "DaneIdentyfikacyjne", DaneIdentyfikacyjne),
            adres: object_at(element, "Adres", Adres),
            adres_koresp: object_at(element, "AdresKoresp", Adres),
            dane_kontaktowe: dane_kontaktowe_elements.empty? ? nil : dane_kontaktowe_elements,
            rola: text_at(element, "Rola")&.to_i,
            udzial: text_at(element, "Udzial"),
            nr_klienta: text_at(element, "NrKlienta")
          )
        end

        private

        def validate!
          raise ArgumentError, "dane_identyfikacyjne is required" unless @dane_identyfikacyjne
          raise ArgumentError, "rola is required and must be 1..11 (TRolaPodmiotu3)" unless ROLA_VALUES.include?(@rola)
          raise ArgumentError, "id_nabywcy must be max 32 characters" if @id_nabywcy && @id_nabywcy.length > 32
          raise ArgumentError, "dane_kontaktowe can have max 3 items" if @dane_kontaktowe && @dane_kontaktowe.length > 3
        end
      end
    end
  end
end
