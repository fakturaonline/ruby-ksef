# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Fa - hlavní část faktury
    class Fa < BaseDTO
      include XMLSerializable

      attr_reader :kod_waluty, :kurs_waluty, :p_1, :p_2, :p_15, :fa_wiersz, :adnotacje, :rodzaj_faktury,
                  :p_13_1, :p_14_1, :p_14_1w, :p_13_2, :p_14_2, :p_14_2w,
                  :p_13_3, :p_14_3, :p_14_3w, :p_13_4, :p_14_4, :p_14_4w,
                  :p_13_5, :p_14_5,
                  :p_13_6_1, :p_13_6_2, :p_13_6_3,
                  :p_13_7, :p_13_8, :p_13_9, :p_13_10, :p_13_11,
                  :p_1m, :p_6, :platnosc,
                  :dane_fa_korygowanej, :tp

      # FA(3) format — pole P_13_X / P_14_X podle oficiálního XSD schematu:
      #   P_13_1 / P_14_1 — základní sazba (aktuálně 23% nebo 22%)
      #   P_13_2 / P_14_2 — obniżona pierwsza (aktuálně 8% nebo 7%)
      #   P_13_3 / P_14_3 — obniżona druga (aktuálně 5%)
      #   P_13_4 / P_14_4 — ryczałt dla taksówek osobowych (NE generické 0%!)
      #   P_13_5 / P_14_5 — procedura szczególna (dział XII rozdz. 6a — OSS/IOSS), NE „zwolniona"!
      #   P_13_6_1 — sprzedaż 0% (tuzemsko, mimo WDT/export)
      #   P_13_6_2 — sprzedaż 0% při WDT (intra-community supply)
      #   P_13_6_3 — sprzedaż 0% při eksportu
      #   P_13_7   — sprzedaż zwolniona od podatku (pole pro „zw")
      #   P_13_8   — dostawa towarów / świadczenie usług poza terytorium kraju
      #   P_13_9   — usługi art. 100 ust. 1 pkt 4
      #   P_13_10  — reverse charge krajowy (art. 17 ust. 1 pkt 7, 8)
      #   P_13_11  — procedura marży (art. 119 a 120)
      #
      # @param kod_waluty [ValueObjects::KodWaluty] Kód měny
      # @param kurs_waluty [Numeric, nil] Kurz měny (PLN za 1 jednotku cizí měny); povinné pokud KodWaluty != PLN
      # @param p_1 [Date, String] Datum vystavení
      # @param p_2 [String] Číslo faktury
      # @param p_15 [Numeric] Částka k zaplacení celkem
      # @param fa_wiersz [Array<DTOs::FaWiersz>] Položky faktury
      # @param adnotacje [DTOs::Adnotacje] Poznámky
      # @param rodzaj_faktury [ValueObjects::RodzajFaktury] Typ faktury
      # @param p_13_1 [Numeric, nil] Základ standardní sazby (23%/22%)
      # @param p_14_1 [Numeric, nil] DPH standardní sazby (v měně faktury)
      # @param p_14_1w [Numeric, nil] DPH standardní sazby v PLN (povinné pro cizí měnu)
      # @param p_13_2 [Numeric, nil] Základ obniżonej pierwszej (8%/7%)
      # @param p_14_2 [Numeric, nil] DPH obniżonej pierwszej (v měně faktury)
      # @param p_14_2w [Numeric, nil] DPH obniżonej pierwszej v PLN
      # @param p_13_3 [Numeric, nil] Základ obniżonej drugiej (5%)
      # @param p_14_3 [Numeric, nil] DPH obniżonej drugiej (v měně faktury)
      # @param p_14_3w [Numeric, nil] DPH obniżonej drugiej v PLN
      # @param p_13_4 [Numeric, nil] Základ ryczałtu dla taksówek osobowych
      # @param p_14_4 [Numeric, nil] Daň z ryczałtu dla taksówek osobowych
      # @param p_14_4w [Numeric, nil] Daň z ryczałtu v PLN
      # @param p_13_5 [Numeric, nil] Základ procedury szczególnej (dział XII rozdz. 6a — OSS/IOSS)
      # @param p_14_5 [Numeric, nil] Daň procedury szczególnej
      # @param p_13_6_1 [Numeric, nil] Sprzedaż 0% (tuzemsko, mimo WDT/export)
      # @param p_13_6_2 [Numeric, nil] Sprzedaż 0% při WDT
      # @param p_13_6_3 [Numeric, nil] Sprzedaż 0% při eksportu
      # @param p_13_7 [Numeric, nil] Sprzedaż zwolniona od podatku (pole pro „zw")
      # @param p_13_8 [Numeric, nil] Dostawa/usługi poza terytorium kraju
      # @param p_13_9 [Numeric, nil] Usługi art. 100 ust. 1 pkt 4
      # @param p_13_10 [Numeric, nil] Reverse charge krajowy (art. 17 ust. 1 pkt 7, 8)
      # @param p_13_11 [Numeric, nil] Procedura marży (art. 119, 120)
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
        p_13_6_1: nil,
        p_13_6_2: nil,
        p_13_6_3: nil,
        p_13_7: nil,
        p_13_8: nil,
        p_13_9: nil,
        p_13_10: nil,
        p_13_11: nil,
        p_1m: nil,
        p_6: nil,
        platnosc: nil,
        dane_fa_korygowanej: nil,
        tp: nil
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
        @p_13_6_1 = p_13_6_1
        @p_13_6_2 = p_13_6_2
        @p_13_6_3 = p_13_6_3
        @p_13_7  = p_13_7
        @p_13_8  = p_13_8
        @p_13_9  = p_13_9
        @p_13_10 = p_13_10
        @p_13_11 = p_13_11
        @platnosc = platnosc
        @dane_fa_korygowanej = Array(dane_fa_korygowanej).compact
        @tp = tp
      end

      def to_rexml # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
        doc = REXML::Document.new
        fa = doc.add_element("Fa")

        # KodWaluty
        add_element_if_present(fa, "KodWaluty", @kod_waluty)

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

        # Ryczałt dla taksówek osobowych
        if @p_13_4 || @p_14_4
          add_element_if_present(fa, "P_13_4",  format_decimal(@p_13_4))  if @p_13_4
          add_element_if_present(fa, "P_14_4",  format_decimal(@p_14_4))  if @p_14_4
          add_element_if_present(fa, "P_14_4W", format_decimal(@p_14_4w)) if @p_14_4w
        end

        # Procedura szczególna (dział XII rozdz. 6a — OSS/IOSS)
        if @p_13_5 || @p_14_5
          add_element_if_present(fa, "P_13_5", format_decimal(@p_13_5)) if @p_13_5
          add_element_if_present(fa, "P_14_5", format_decimal(@p_14_5)) if @p_14_5
        end

        # Sazba 0% — P_13_6_1 (tuzemsko) / P_13_6_2 (WDT) / P_13_6_3 (eksport)
        add_element_if_present(fa, "P_13_6_1", format_decimal(@p_13_6_1)) if @p_13_6_1
        add_element_if_present(fa, "P_13_6_2", format_decimal(@p_13_6_2)) if @p_13_6_2
        add_element_if_present(fa, "P_13_6_3", format_decimal(@p_13_6_3)) if @p_13_6_3

        # Sprzedaż zwolniona od podatku (pole pro „zw")
        add_element_if_present(fa, "P_13_7", format_decimal(@p_13_7)) if @p_13_7

        # Dostawa/usługi poza terytorium kraju
        add_element_if_present(fa, "P_13_8", format_decimal(@p_13_8)) if @p_13_8

        # Usługi art. 100 ust. 1 pkt 4
        add_element_if_present(fa, "P_13_9", format_decimal(@p_13_9)) if @p_13_9

        # Reverse charge krajowy (art. 17 ust. 1 pkt 7, 8)
        add_element_if_present(fa, "P_13_10", format_decimal(@p_13_10)) if @p_13_10

        # Procedura marży (art. 119, 120)
        add_element_if_present(fa, "P_13_11", format_decimal(@p_13_11)) if @p_13_11

        # P_15 - částka celkem
        add_element_if_present(fa, "P_15", format_decimal(@p_15))

        # KursWalutyZ - kurz cizí měny (povinné pokud KodWaluty != PLN); přesnost 6 des. míst
        # FA(3) XSD: element name is KursWalutyZ (not KursWaluty), comes after P_15, before Adnotacje
        add_element_if_present(fa, "KursWalutyZ", format_rate(@kurs_waluty)) if @kurs_waluty

        # Adnotacje
        add_child_element(fa, @adnotacje)

        # RodzajFaktury
        add_element_if_present(fa, "RodzajFaktury", @rodzaj_faktury)

        # DaneFaKorygowanej - data původní faktury (KOR/KOR_ZAL/KOR_ROZ)
        add_child_elements(fa, @dane_fa_korygowanej)

        # TP - Transakcje powiązane (connected parties) — XSD řádek 3037, před FaWiersz
        add_element_if_present(fa, "TP", @tp) if @tp

        # FaWiersz - položky
        add_child_elements(fa, @fa_wiersz)

        # Platnosc - platební podmínky
        add_child_element(fa, @platnosc) if @platnosc

        doc
      end

      def self.from_nokogiri(element)
        new(
          kod_waluty: ValueObjects::KodWaluty.new(text_at(element, "KodWaluty")),
          kurs_waluty: decimal_at(element, "KursWalutyZ"),
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
          p_13_6_1: decimal_at(element, "P_13_6_1"),
          p_13_6_2: decimal_at(element, "P_13_6_2"),
          p_13_6_3: decimal_at(element, "P_13_6_3"),
          p_13_7:  decimal_at(element, "P_13_7"),
          p_13_8:  decimal_at(element, "P_13_8"),
          p_13_9:  decimal_at(element, "P_13_9"),
          p_13_10: decimal_at(element, "P_13_10"),
          p_13_11: decimal_at(element, "P_13_11"),
          p_15: decimal_at(element, "P_15"),
          adnotacje: object_at(element, "Adnotacje", DTOs::Adnotacje) || DTOs::Adnotacje.new,
          rodzaj_faktury: ValueObjects::RodzajFaktury.new(text_at(element, "RodzajFaktury") || "VAT"),
          fa_wiersz: array_at(element, "FaWiersz", DTOs::FaWiersz),
          platnosc: object_at(element, "Platnosc", DTOs::Platnosc),
          dane_fa_korygowanej: array_at(element, "DaneFaKorygowanej", DTOs::DaneFaKorygowanej),
          tp: text_at(element, "TP")&.to_i
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
