# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # TerminPlatnosci - termín platby
      class TerminPlatnosci < BaseDTO
        include XMLSerializable

        attr_reader :termin, :forma_platnosci, :suma_platnosci

        # @param termin [Date, String] Datum splatnosti
        # @param forma_platnosci [String, nil] Forma platby (1-7): 1=gotówka, 6=przelew
        # @param suma_platnosci [Numeric, nil] Částka k úhradě
        def initialize(termin:, forma_platnosci: nil, suma_platnosci: nil)
          @termin = termin.is_a?(String) ? Date.parse(termin) : termin
          @forma_platnosci = forma_platnosci
          @suma_platnosci = suma_platnosci
        end

        def to_rexml
          doc = REXML::Document.new
          termin_elem = doc.add_element("TerminPlatnosci")

          add_element_if_present(termin_elem, "Termin", @termin.strftime("%Y-%m-%d"))
          add_element_if_present(termin_elem, "FormaPlatnosci", @forma_platnosci)
          add_element_if_present(termin_elem, "SumaPlatnosci", format_decimal(@suma_platnosci)) if @suma_platnosci

          doc
        end

        def self.from_nokogiri(element)
          new(
            termin: date_at(element, "Termin"),
            forma_platnosci: text_at(element, "FormaPlatnosci"),
            suma_platnosci: decimal_at(element, "SumaPlatnosci")
          )
        end

        private

        def format_decimal(value)
          return nil if value.nil?

          "%.2f" % value
        end
      end
    end
  end
end
