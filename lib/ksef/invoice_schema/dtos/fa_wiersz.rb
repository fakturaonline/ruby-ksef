# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # FaWiersz - pozycja faktury (invoice line item)
      class FaWiersz < BaseDTO
        include XMLSerializable

        attr_reader :nr_wiersza, :p_7, :p_8a, :p_8b, :p_9a, :p_9b, :p_11, :p_11a, :p_12, :cena_jednostkowa, :wartosc_pozycji_smr

        # @param nr_wiersza [Integer] Numer wiersza
        # @param p_7 [String] Nazwa towaru lub usługi
        # @param p_8a [String, nil] Miara (jednostka)
        # @param p_8b [Numeric, nil] Ilość
        # @param p_9a [Numeric, nil] Cena jednostkowa netto
        # @param p_9b [Numeric, nil] Wartość netto
        # @param p_11 [Numeric] Stawka VAT (procent lub "zw", "np", "oo")
        # @param p_11a [String, nil] Oznaczenie procedury
        # @param p_12 [Numeric] Wartość podatku
        # @param cena_jednostkowa [Numeric, nil] Cena jednostkowa brutto (optional)
        # @param wartosc_pozycji_smr [Numeric, nil] Wartość pozycji brutto (optional)
        def initialize(
          nr_wiersza:,
          p_7:,
          p_9b:,
          p_11:,
          p_12:,
          p_8a: nil,
          p_8b: nil,
          p_9a: nil,
          p_11a: nil,
          cena_jednostkowa: nil,
          wartosc_pozycji_smr: nil
        )
          @nr_wiersza = nr_wiersza
          @p_7 = p_7
          @p_8a = p_8a
          @p_8b = p_8b
          @p_9a = p_9a
          @p_9b = p_9b
          @p_11 = p_11
          @p_11a = p_11a
          @p_12 = p_12
          @cena_jednostkowa = cena_jednostkowa
          @wartosc_pozycji_smr = wartosc_pozycji_smr
        end

        def to_rexml
          doc = REXML::Document.new
          wiersz = doc.add_element('FaWiersz')

          add_element_if_present(wiersz, 'NrWiersza', @nr_wiersza)
          add_element_if_present(wiersz, 'P_7', @p_7)
          add_element_if_present(wiersz, 'P_8A', @p_8a)
          add_element_if_present(wiersz, 'P_8B', format_decimal(@p_8b)) if @p_8b
          add_element_if_present(wiersz, 'P_9A', format_decimal(@p_9a)) if @p_9a
          add_element_if_present(wiersz, 'P_9B', format_decimal(@p_9b))
          add_element_if_present(wiersz, 'P_11', @p_11)
          add_element_if_present(wiersz, 'P_11A', @p_11a)
          add_element_if_present(wiersz, 'P_12', format_decimal(@p_12))
          add_element_if_present(wiersz, 'CenaJednostkowa', format_decimal(@cena_jednostkowa)) if @cena_jednostkowa
          add_element_if_present(wiersz, 'WartoscPozycjiSMR', format_decimal(@wartosc_pozycji_smr)) if @wartosc_pozycji_smr

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
end
