# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # RachunekBankowy - bankovní účet
      class RachunekBankowy < BaseDTO
        include XMLSerializable

        attr_reader :nr_rb, :swift, :nazwa_banku, :opis_rachunku

        # @param nr_rb [String] Číslo účtu / IBAN
        # @param swift [String, nil] SWIFT/BIC kód
        # @param nazwa_banku [String, nil] Název banky
        # @param opis_rachunku [String, nil] Popis účtu
        def initialize(nr_rb:, swift: nil, nazwa_banku: nil, opis_rachunku: nil)
          @nr_rb = nr_rb
          @swift = swift
          @nazwa_banku = nazwa_banku
          @opis_rachunku = opis_rachunku
        end

        def to_rexml
          doc = REXML::Document.new
          rachunek = doc.add_element('RachunekBankowy')

          # IBAN nebo NrRB podle formátu
          if @nr_rb =~ /^[A-Z]{2}\d{2}/
            add_element_if_present(rachunek, 'NrRBIBAN', @nr_rb)
          else
            add_element_if_present(rachunek, 'NrRB', @nr_rb)
          end

          add_element_if_present(rachunek, 'SWIFT', @swift)
          add_element_if_present(rachunek, 'NazwaBanku', @nazwa_banku)
          add_element_if_present(rachunek, 'OpisRachunku', @opis_rachunku)

          doc
        end
      end
    end
  end
end
