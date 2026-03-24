# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # DaneFaKorygowanej - data o korekté fakturě (FA(3) KOR/KOR_ZAL/KOR_ROZ)
      #
      # Povinné pro RodzajFaktury = KOR, KOR_ZAL nebo KOR_ROZ.
      # Obsahuje odkaz na původní fakturu.
      #
      # Výběr (choice) — přesně jeden z:
      #   - nr_ksef_fa_korygowanej: KSeF číslo původní faktury (pokud byla vydána přes KSeF)
      #   - nr_ksef_n: 1  (pokud původní faktura nebyla vydána přes KSeF)
      class DaneFaKorygowanej < BaseDTO
        include XMLSerializable

        attr_reader :data_wyst_fa_korygowanej, :nr_fa_korygowanej,
                    :nr_ksef_fa_korygowanej, :nr_ksef_n

        # @param data_wyst_fa_korygowanej [Date, String] Datum vystavení původní faktury (povinné)
        # @param nr_fa_korygowanej [String] Číslo původní faktury (povinné)
        # @param nr_ksef_fa_korygowanej [String, nil] KSeF číslo původní faktury (použij, pokud existuje)
        # @param nr_ksef_n [Integer, nil] 1 = původní faktura nebyla vydána přes KSeF
        def initialize(
          data_wyst_fa_korygowanej:,
          nr_fa_korygowanej:,
          nr_ksef_fa_korygowanej: nil,
          nr_ksef_n: nil
        )
          @data_wyst_fa_korygowanej = data_wyst_fa_korygowanej.is_a?(String) ? Date.parse(data_wyst_fa_korygowanej) : data_wyst_fa_korygowanej
          @nr_fa_korygowanej = nr_fa_korygowanej
          @nr_ksef_fa_korygowanej = nr_ksef_fa_korygowanej
          @nr_ksef_n = nr_ksef_n

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          element = doc.add_element("DaneFaKorygowanej")

          add_element_if_present(element, "DataWystFaKorygowanej", @data_wyst_fa_korygowanej.strftime("%Y-%m-%d"))
          add_element_if_present(element, "NrFaKorygowanej", @nr_fa_korygowanej)

          if @nr_ksef_fa_korygowanej
            add_element_if_present(element, "NrKSeF", 1)
            add_element_if_present(element, "NrKSeFFaKorygowanej", @nr_ksef_fa_korygowanej)
          else
            add_element_if_present(element, "NrKSeFN", @nr_ksef_n)
          end

          doc
        end

        def self.from_nokogiri(element)
          return nil unless element

          new(
            data_wyst_fa_korygowanej: date_at(element, "DataWystFaKorygowanej"),
            nr_fa_korygowanej: text_at(element, "NrFaKorygowanej"),
            nr_ksef_fa_korygowanej: text_at(element, "NrKSeFFaKorygowanej"),
            nr_ksef_n: integer_at(element, "NrKSeFN")
          )
        end

        private

        def validate!
          raise ArgumentError, "data_wyst_fa_korygowanej is required" if @data_wyst_fa_korygowanej.nil?
          raise ArgumentError, "nr_fa_korygowanej is required" if @nr_fa_korygowanej.blank?

          both_set = !@nr_ksef_fa_korygowanej.nil? && !@nr_ksef_n.nil?
          raise ArgumentError, "Specify either nr_ksef_fa_korygowanej or nr_ksef_n, not both" if both_set

          neither_set = @nr_ksef_fa_korygowanej.nil? && @nr_ksef_n.nil?
          raise ArgumentError, "Either nr_ksef_fa_korygowanej or nr_ksef_n must be set" if neither_set
        end
      end
    end
  end
end
