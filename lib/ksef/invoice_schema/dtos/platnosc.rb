# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Platnosc - platební podmínky
      class Platnosc < BaseDTO
        include XMLSerializable

        attr_reader :termin_platnosci, :rachunek_bankowy, :forma_platnosci

        # @param termin_platnosci [Array<TerminPlatnosci>, TerminPlatnosci, nil] Termíny platby
        # @param rachunek_bankowy [Array<RachunekBankowy>, RachunekBankowy, nil] Bankovní účty
        # @param forma_platnosci [String, nil] Hlavní forma platby (1-7)
        def initialize(termin_platnosci: nil, rachunek_bankowy: nil, forma_platnosci: nil)
          @termin_platnosci = Array(termin_platnosci).compact if termin_platnosci
          @rachunek_bankowy = Array(rachunek_bankowy).compact if rachunek_bankowy
          @forma_platnosci = forma_platnosci
        end

        def to_rexml
          doc = REXML::Document.new
          platnosc = doc.add_element("Platnosc")

          # Termíny platby
          if @termin_platnosci && !@termin_platnosci.empty?
            @termin_platnosci.each do |termin|
              add_child_element(platnosc, termin)
            end
          end

          # Forma platby
          add_element_if_present(platnosc, "FormaPlatnosci", @forma_platnosci)

          # Bankovní účty
          if @rachunek_bankowy && !@rachunek_bankowy.empty?
            @rachunek_bankowy.each do |rachunek|
              add_child_element(platnosc, rachunek)
            end
          end

          doc
        end
      end
    end
  end
end
