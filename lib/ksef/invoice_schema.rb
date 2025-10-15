# frozen_string_literal: true

require_relative "invoice_schema/xml_serializable"
require_relative "invoice_schema/base_dto"

# Value Objects
require_relative "invoice_schema/value_objects/kod_waluty"
require_relative "invoice_schema/value_objects/form_code"
require_relative "invoice_schema/value_objects/rodzaj_faktury"

# DTOs
require_relative "invoice_schema/dtos/adres"
require_relative "invoice_schema/dtos/dane_identyfikacyjne"
require_relative "invoice_schema/dtos/dane_kontaktowe"
require_relative "invoice_schema/dtos/podmiot1"
require_relative "invoice_schema/dtos/podmiot2"
require_relative "invoice_schema/dtos/fa_wiersz"
require_relative "invoice_schema/dtos/adnotacje"
require_relative "invoice_schema/dtos/rachunek_bankowy"
require_relative "invoice_schema/dtos/termin_platnosci"
require_relative "invoice_schema/dtos/platnosc"
require_relative "invoice_schema/dtos/stopka"

# Main components
require_relative "invoice_schema/naglowek"
require_relative "invoice_schema/fa"
require_relative "invoice_schema/faktura"

module KSEF
  # Modul pro vytváření FA(2) XML faktur
  module InvoiceSchema
    # Rychlý helper pro vytvoření faktury
    # @return [Faktura] Instance faktury připravená k vyplnění
    def self.build
      Faktura.new(
        naglowek: Naglowek.new,
        podmiot1: nil,  # user must provide
        podmiot2: nil,  # user must provide
        fa: nil         # user must provide
      )
    end
  end
end
