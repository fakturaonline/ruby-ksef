# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Fa - hlavní část faktury
    class Fa < BaseDTO
      include XMLSerializable

      attr_reader :kod_waluty, :p_1, :p_2, :p_15, :fa_wiersz, :adnotacje, :rodzaj_faktury,
                  :p_13_1, :p_13_2, :p_13_3, :p_13_4, :p_13_5, :p_13_6

      # @param kod_waluty [ValueObjects::KodWaluty] Kód měny
      # @param p_1 [Date, String] Datum vystavení
      # @param p_2 [String] Číslo faktury
      # @param p_15 [Numeric] Částka k zaplacení celkem
      # @param fa_wiersz [Array<DTOs::FaWiersz>] Položky faktury
      # @param adnotacje [DTOs::Adnotacje] Poznámky
      # @param rodzaj_faktury [ValueObjects::RodzajFaktury] Typ faktury
      # @param p_13_1 [Numeric, nil] Suma hodnot základu daně dle sazby 23%
      # @param p_13_2 [Numeric, nil] Suma DPH dle sazby 23%
      # @param p_13_3 [Numeric, nil] Suma hodnot základu daně dle sazby 8%
      # @param p_13_4 [Numeric, nil] Suma DPH dle sazby 8%
      # @param p_13_5 [Numeric, nil] Suma hodnot základu daně dle sazby 5%
      # @param p_13_6 [Numeric, nil] Suma DPH dle sazby 5%
      def initialize(
        kod_waluty:,
        p_1:,
        p_2:,
        p_15:,
        fa_wiersz: [],
        adnotacje: DTOs::Adnotacje.new,
        rodzaj_faktury: ValueObjects::RodzajFaktury.new,
        p_13_1: nil,
        p_13_2: nil,
        p_13_3: nil,
        p_13_4: nil,
        p_13_5: nil,
        p_13_6: nil
      )
        @kod_waluty = kod_waluty.is_a?(ValueObjects::KodWaluty) ? kod_waluty : ValueObjects::KodWaluty.new(kod_waluty)
        @p_1 = p_1.is_a?(String) ? Date.parse(p_1) : p_1
        @p_2 = p_2
        @p_15 = p_15
        @fa_wiersz = fa_wiersz
        @adnotacje = adnotacje
        @rodzaj_faktury = rodzaj_faktury.is_a?(ValueObjects::RodzajFaktury) ? rodzaj_faktury : ValueObjects::RodzajFaktury.new(rodzaj_faktury)
        @p_13_1 = p_13_1
        @p_13_2 = p_13_2
        @p_13_3 = p_13_3
        @p_13_4 = p_13_4
        @p_13_5 = p_13_5
        @p_13_6 = p_13_6
      end

      def to_rexml
        doc = REXML::Document.new
        fa = doc.add_element('Fa')

        # KodWaluty
        add_element_if_present(fa, 'KodWaluty', @kod_waluty)

        # P_1 - datum vystavení
        add_element_if_present(fa, 'P_1', @p_1.strftime('%Y-%m-%d'))

        # P_2 - číslo faktury
        add_element_if_present(fa, 'P_2', @p_2)

        # P_13_* - sumy podle DPH sazeb
        add_element_if_present(fa, 'P_13_1', format_decimal(@p_13_1)) if @p_13_1
        add_element_if_present(fa, 'P_13_2', format_decimal(@p_13_2)) if @p_13_2
        add_element_if_present(fa, 'P_13_3', format_decimal(@p_13_3)) if @p_13_3
        add_element_if_present(fa, 'P_13_4', format_decimal(@p_13_4)) if @p_13_4
        add_element_if_present(fa, 'P_13_5', format_decimal(@p_13_5)) if @p_13_5
        add_element_if_present(fa, 'P_13_6', format_decimal(@p_13_6)) if @p_13_6

        # P_15 - částka celkem
        add_element_if_present(fa, 'P_15', format_decimal(@p_15))

        # Adnotacje
        add_child_element(fa, @adnotacje)

        # RodzajFaktury
        add_element_if_present(fa, 'RodzajFaktury', @rodzaj_faktury)

        # FaWiersz - položky
        add_child_elements(fa, @fa_wiersz)

        doc
      end

      private

      def format_decimal(value)
        return nil if value.nil?
        '%.2f' % value
      end
    end
  end
end
