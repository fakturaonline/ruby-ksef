# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Fa - hlavní část faktury
    class Fa < BaseDTO
      include XMLSerializable

      attr_reader :kod_waluty, :kurs_waluty, :p_1, :p_2, :p_15, :fa_wiersz, :adnotacje, :rodzaj_faktury,
                  :p_13_1, :p_14_1, :p_14_1w, :p_13_2, :p_14_2, :p_14_2w,
                  :p_13_3, :p_14_3, :p_14_3w, :p_13_4, :p_14_4, :p_14_4w,
                  :p_13_5, :p_14_5, :p_1m, :p_6, :platnosc,
                  :dane_fa_korygowanej

      # FA(3) format - správné názvy podle XSD:
      # P_13_1 = základ daně 23%, P_14_1 = DPH 23%
      # P_13_2 = základ daně 8%, P_14_2 = DPH 8%
      # P_13_3 = základ daně 5%, P_14_3 = DPH 5%
      # P_13_4 = základ daně 0%, P_14_4 = DPH 0%
      # P_13_5 = základ osvobozené, P_14_5 = částka osvobozené
      #
      # @param kod_waluty [ValueObjects::KodWaluty] Kód měny
      # @param kurs_waluty [Numeric, nil] Kurz měny (PLN za 1 jednotku cizí měny); povinné pokud KodWaluty != PLN
      # @param p_1 [Date, String] Datum vystavení
      # @param p_2 [String] Číslo faktury
      # @param p_15 [Numeric] Částka k zaplacení celkem
      # @param fa_wiersz [Array<DTOs::FaWiersz>] Položky faktury
      # @param adnotacje [DTOs::Adnotacje] Poznámky
      # @param rodzaj_faktury [ValueObjects::RodzajFaktury] Typ faktury
      # @param p_13_1 [Numeric, nil] Základ daně 23%
      # @param p_14_1 [Numeric, nil] DPH 23% (v měně faktury)
      # @param p_14_1w [Numeric, nil] DPH 23% v PLN (povinné pro cizí měnu)
      # @param p_13_2 [Numeric, nil] Základ daně 8%
      # @param p_14_2 [Numeric, nil] DPH 8% (v měně faktury)
      # @param p_14_2w [Numeric, nil] DPH 8% v PLN
      # @param p_13_3 [Numeric, nil] Základ daně 5%
      # @param p_14_3 [Numeric, nil] DPH 5% (v měně faktury)
      # @param p_14_3w [Numeric, nil] DPH 5% v PLN
      # @param p_13_4 [Numeric, nil] Základ daně 0%
      # @param p_14_4 [Numeric, nil] DPH 0%
      # @param p_14_4w [Numeric, nil] DPH 0% v PLN
      # @param p_13_5 [Numeric, nil] Základ osvobozený
      # @param p_14_5 [Numeric, nil] Částka osvobozená
      # @param p_1m [String, nil] Místo vystavení
      # @param p_6 [Date, String, nil] Datum zdanitelného plnění (DUZP)
      # @param platnosc [DTOs::Platnosc, nil] Platební podmínky
      # @param dane_fa_korygowanej [Array<DTOs::DaneFaKorygowanej>, DTOs::DaneFaKorygowanej, nil] Data původní faktury (KOR/KOR_ZAL/KOR_ROZ)
      def initialize(
        kod_waluty:,
        p_1:,
        p_2:,
        p_15:,
        kurs_waluty: nil,
        fa_wiersz: [],
        adnotacje: DTOs::Adnotacje.new,
        rodzaj_faktury: ValueObjects::RodzajFaktury.new,
        p_13_1: nil,
        p_14_1: nil,
        p_14_1w: nil,
        p_13_2: nil,
        p_14_2: nil,
        p_14_2w: nil,
        p_13_3: nil,
        p_14_3: nil,
        p_14_3w: nil,
        p_13_4: nil,
        p_14_4: nil,
        p_14_4w: nil,
        p_13_5: nil,
        p_14_5: nil,
        p_1m: nil,
        p_6: nil,
        platnosc: nil,
        dane_fa_korygowanej: nil
      )
        @kod_waluty = kod_waluty.is_a?(ValueObjects::KodWaluty) ? kod_waluty : ValueObjects::KodWaluty.new(kod_waluty)
        @kurs_waluty = kurs_waluty
        @p_1 = p_1.is_a?(String) ? Date.parse(p_1) : p_1
        @p_1m = p_1m
        @p_2 = p_2
        @p_6 = p_6.is_a?(String) ? Date.parse(p_6) : p_6 if p_6
        @p_15 = p_15
        @fa_wiersz = fa_wiersz
        @adnotacje = adnotacje
        @rodzaj_faktury = rodzaj_faktury.is_a?(ValueObjects::RodzajFaktury) ? rodzaj_faktury : ValueObjects::RodzajFaktury.new(rodzaj_faktury)
        # FA(3): každá sazba má P_13_X (základ), P_14_X (daň v měně faktury), P_14_XW (daň v PLN)
        @p_13_1  = p_13_1
        @p_14_1  = p_14_1
        @p_14_1w = p_14_1w
        @p_13_2  = p_13_2
        @p_14_2  = p_14_2
        @p_14_2w = p_14_2w
        @p_13_3  = p_13_3
        @p_14_3  = p_14_3
        @p_14_3w = p_14_3w
        @p_13_4  = p_13_4
        @p_14_4  = p_14_4
        @p_14_4w = p_14_4w
        @p_13_5  = p_13_5
        @p_14_5  = p_14_5
        @platnosc = platnosc
        @dane_fa_korygowanej = Array(dane_fa_korygowanej).compact
      end

      def to_rexml # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
        doc = REXML::Document.new
        fa = doc.add_element("Fa")

        # KodWaluty
        add_element_if_present(fa, "KodWaluty", @kod_waluty)

        # KursWaluty - kurz cizí měny (povinné pokud KodWaluty != PLN); přesnost 6 des. míst
        add_element_if_present(fa, "KursWaluty", format_rate(@kurs_waluty)) if @kurs_waluty

        # P_1 - datum vystavení
        add_element_if_present(fa, "P_1", @p_1.strftime("%Y-%m-%d"))

        # P_1M - místo vystavení
        add_element_if_present(fa, "P_1M", @p_1m) if @p_1m

        # P_2 - číslo faktury
        add_element_if_present(fa, "P_2", @p_2)

        # P_6 - datum zdanitelného plnění (DUZP)
        add_element_if_present(fa, "P_6", @p_6.strftime("%Y-%m-%d")) if @p_6

        # FA(3): Každá sazba DPH jako skupina (P_13_X + P_14_X)
        # Sazba 23%
        if @p_13_1 || @p_14_1
          add_element_if_present(fa, "P_13_1",  format_decimal(@p_13_1))  if @p_13_1
          add_element_if_present(fa, "P_14_1",  format_decimal(@p_14_1))  if @p_14_1
          add_element_if_present(fa, "P_14_1W", format_decimal(@p_14_1w)) if @p_14_1w
        end

        # Sazba 8%
        if @p_13_2 || @p_14_2
          add_element_if_present(fa, "P_13_2",  format_decimal(@p_13_2))  if @p_13_2
          add_element_if_present(fa, "P_14_2",  format_decimal(@p_14_2))  if @p_14_2
          add_element_if_present(fa, "P_14_2W", format_decimal(@p_14_2w)) if @p_14_2w
        end

        # Sazba 5%
        if @p_13_3 || @p_14_3
          add_element_if_present(fa, "P_13_3",  format_decimal(@p_13_3))  if @p_13_3
          add_element_if_present(fa, "P_14_3",  format_decimal(@p_14_3))  if @p_14_3
          add_element_if_present(fa, "P_14_3W", format_decimal(@p_14_3w)) if @p_14_3w
        end

        # Sazba 0%
        if @p_13_4 || @p_14_4
          add_element_if_present(fa, "P_13_4",  format_decimal(@p_13_4))  if @p_13_4
          add_element_if_present(fa, "P_14_4",  format_decimal(@p_14_4))  if @p_14_4
          add_element_if_present(fa, "P_14_4W", format_decimal(@p_14_4w)) if @p_14_4w
        end

        # Osvobozeno
        if @p_13_5 || @p_14_5
          add_element_if_present(fa, "P_13_5", format_decimal(@p_13_5)) if @p_13_5
          add_element_if_present(fa, "P_14_5", format_decimal(@p_14_5)) if @p_14_5
        end

        # P_15 - částka celkem
        add_element_if_present(fa, "P_15", format_decimal(@p_15))

        # Adnotacje
        add_child_element(fa, @adnotacje)

        # RodzajFaktury
        add_element_if_present(fa, "RodzajFaktury", @rodzaj_faktury)

        # DaneFaKorygowanej - data původní faktury (KOR/KOR_ZAL/KOR_ROZ)
        add_child_elements(fa, @dane_fa_korygowanej)

        # FaWiersz - položky
        add_child_elements(fa, @fa_wiersz)

        # Platnosc - platební podmínky
        add_child_element(fa, @platnosc) if @platnosc

        doc
      end

      def self.from_nokogiri(element)
        new(
          kod_waluty: ValueObjects::KodWaluty.new(text_at(element, "KodWaluty")),
          kurs_waluty: decimal_at(element, "KursWaluty"),
          p_1: date_at(element, "P_1"),
          p_1m: text_at(element, "P_1M"),
          p_2: text_at(element, "P_2"),
          p_6: date_at(element, "P_6"),
          p_13_1:  decimal_at(element, "P_13_1"),
          p_14_1:  decimal_at(element, "P_14_1"),
          p_14_1w: decimal_at(element, "P_14_1W"),
          p_13_2:  decimal_at(element, "P_13_2"),
          p_14_2:  decimal_at(element, "P_14_2"),
          p_14_2w: decimal_at(element, "P_14_2W"),
          p_13_3:  decimal_at(element, "P_13_3"),
          p_14_3:  decimal_at(element, "P_14_3"),
          p_14_3w: decimal_at(element, "P_14_3W"),
          p_13_4:  decimal_at(element, "P_13_4"),
          p_14_4:  decimal_at(element, "P_14_4"),
          p_14_4w: decimal_at(element, "P_14_4W"),
          p_13_5:  decimal_at(element, "P_13_5"),
          p_14_5:  decimal_at(element, "P_14_5"),
          p_15: decimal_at(element, "P_15"),
          adnotacje: object_at(element, "Adnotacje", DTOs::Adnotacje) || DTOs::Adnotacje.new,
          rodzaj_faktury: ValueObjects::RodzajFaktury.new(text_at(element, "RodzajFaktury") || "VAT"),
          fa_wiersz: array_at(element, "FaWiersz", DTOs::FaWiersz),
          platnosc: object_at(element, "Platnosc", DTOs::Platnosc),
          dane_fa_korygowanej: array_at(element, "DaneFaKorygowanej", DTOs::DaneFaKorygowanej)
        )
      end

      private

      def format_decimal(value)
        return nil if value.nil?

        "%.2f" % value
      end

      def format_rate(value)
        return nil if value.nil?

        "%.6f" % value
      end
    end
  end
end
