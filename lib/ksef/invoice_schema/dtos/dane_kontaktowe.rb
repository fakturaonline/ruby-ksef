# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # DaneKontaktowe - kontaktní údaje
      class DaneKontaktowe < BaseDTO
        include XMLSerializable

        attr_reader :email, :telefon

        # @param email [String, nil] Email
        # @param telefon [String, nil] Telefon
        def initialize(email: nil, telefon: nil)
          @email = email
          @telefon = telefon
        end

        def to_rexml
          doc = REXML::Document.new
          kontakt = doc.add_element("DaneKontaktowe")

          add_element_if_present(kontakt, "Email", @email)
          add_element_if_present(kontakt, "Telefon", @telefon)

          doc
        end

        def self.from_nokogiri(element)
          new(
            email: text_at(element, "Email"),
            telefon: text_at(element, "Telefon")
          )
        end
      end
    end
  end
end
