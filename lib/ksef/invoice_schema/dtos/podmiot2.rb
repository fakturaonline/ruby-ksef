# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Podmiot2 - nabywca (buyer) - FA(3) format
      #
      # @example
      #   Podmiot2.new(
      #     dane_identyfikacyjne: DaneIdentyfikacyjne.new(nip: "1234567890", nazwa: "Firma s.r.o."),
      #     adres: Adres.new(kod_kraju: "PL", adres_l1: "Testowa 5", adres_l2: "00-001 Warszawa"),
      #     jst: 2,  # 1=ano, 2=ne
      #     gv: 2    # 1=ano, 2=ne
      #   )
      class Podmiot2 < BaseDTO
        include XMLSerializable

        attr_reader :nr_eori, :dane_identyfikacyjne, :adres, :adres_koresp,
                    :dane_kontaktowe, :nr_klienta, :id_nabywcy, :jst, :gv

        # @param dane_identyfikacyjne [DaneIdentyfikacyjne] Dane identyfikacyjne (povinné)
        # @param jst [Integer] Značka jednotky podřízené JST: 1=ano, 2=ne (povinné)
        # @param gv [Integer] Značka člena skupiny VAT: 1=ano, 2=ne (povinné)
        # @param nr_eori [String, nil] Numer EORI nabywcy
        # @param adres [Adres, nil] Adres nabywcy
        # @param adres_koresp [Adres, nil] Adres korespondencyjny
        # @param dane_kontaktowe [Array<DaneKontaktowe>, DaneKontaktowe, nil] Dane kontaktowe (max 3)
        # @param nr_klienta [String, nil] Numer klienta
        # @param id_nabywcy [String, nil] Unikalny klíč pro vazbu dat nabywcy (max 32 znaků)
        def initialize(
          dane_identyfikacyjne:,
          jst:,
          gv:,
          nr_eori: nil,
          adres: nil,
          adres_koresp: nil,
          dane_kontaktowe: nil,
          nr_klienta: nil,
          id_nabywcy: nil
        )
          @nr_eori = nr_eori
          @dane_identyfikacyjne = dane_identyfikacyjne
          @adres = adres
          @adres_koresp = adres_koresp
          @dane_kontaktowe = Array(dane_kontaktowe).compact if dane_kontaktowe
          @nr_klienta = nr_klienta
          @id_nabywcy = id_nabywcy
          @jst = jst
          @gv = gv

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          podmiot = doc.add_element("Podmiot2")

          # 1. NrEORI (volitelné)
          add_element_if_present(podmiot, "NrEORI", @nr_eori) if @nr_eori

          # 2. DaneIdentyfikacyjne (povinné)
          add_child_element(podmiot, @dane_identyfikacyjne)

          # 3. Adres (volitelné)
          add_child_element(podmiot, @adres) if @adres

          # 4. AdresKoresp (volitelné)
          add_child_element(podmiot, @adres_koresp) if @adres_koresp

          # 5. DaneKontaktowe (volitelné, max 3)
          @dane_kontaktowe&.first(3)&.each do |dk|
            add_child_element(podmiot, dk)
          end

          # 6. NrKlienta (volitelné)
          add_element_if_present(podmiot, "NrKlienta", @nr_klienta) if @nr_klienta

          # 7. IDNabywcy (volitelné)
          add_element_if_present(podmiot, "IDNabywcy", @id_nabywcy) if @id_nabywcy

          # 8. JST (povinné)
          add_element_if_present(podmiot, "JST", @jst)

          # 9. GV (povinné)
          add_element_if_present(podmiot, "GV", @gv)

          doc
        end

        def self.from_nokogiri(element)
          dane_kontaktowe_elements = element.xpath("DaneKontaktowe").map do |dk_el|
            DaneKontaktowe.from_nokogiri(dk_el)
          end

          new(
            nr_eori: text_at(element, "NrEORI"),
            dane_identyfikacyjne: object_at(element, "DaneIdentyfikacyjne", DaneIdentyfikacyjne),
            adres: object_at(element, "Adres", Adres),
            adres_koresp: object_at(element, "AdresKoresp", Adres),
            dane_kontaktowe: dane_kontaktowe_elements.empty? ? nil : dane_kontaktowe_elements,
            nr_klienta: text_at(element, "NrKlienta"),
            id_nabywcy: text_at(element, "IDNabywcy"),
            jst: text_at(element, "JST")&.to_i || 2,
            gv: text_at(element, "GV")&.to_i || 2
          )
        end

        private

        def validate!
          raise ArgumentError, "dane_identyfikacyjne is required" unless @dane_identyfikacyjne
          raise ArgumentError, "jst is required and must be 1 or 2" unless [1, 2].include?(@jst)
          raise ArgumentError, "gv is required and must be 1 or 2" unless [1, 2].include?(@gv)
          raise ArgumentError, "id_nabywcy must be max 32 characters" if @id_nabywcy && @id_nabywcy.length > 32
          raise ArgumentError, "dane_kontaktowe can have max 3 items" if @dane_kontaktowe && @dane_kontaktowe.length > 3
        end
      end
    end
  end
end
