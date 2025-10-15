# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Dane identyfikacyjne podmiotu
      class DaneIdentyfikacyjne < BaseDTO
        include XMLSerializable

        attr_reader :nip, :nazwa, :pesel, :id_inny

        # @param nip [String, nil] NIP
        # @param nazwa [String] Nazwa/Imię i nazwisko
        # @param pesel [String, nil] PESEL
        # @param id_inny [Hash, nil] Inny identyfikator {:typ, :numer}
        def initialize(nazwa:, nip: nil, pesel: nil, id_inny: nil)
          @nip = nip
          @nazwa = nazwa
          @pesel = pesel
          @id_inny = id_inny
        end

        def to_rexml
          doc = REXML::Document.new
          dane = doc.add_element("DaneIdentyfikacyjne")

          if @nip
            add_element_if_present(dane, "NIP", @nip)
          elsif @pesel
            add_element_if_present(dane, "PESEL", @pesel)
          elsif @id_inny
            inny = dane.add_element("BrakID")
            add_element_if_present(inny, "Typ", @id_inny[:typ])
            add_element_if_present(inny, "Numer", @id_inny[:numer])
          end

          add_element_if_present(dane, "Nazwa", @nazwa)

          doc
        end
      end
    end
  end
end
