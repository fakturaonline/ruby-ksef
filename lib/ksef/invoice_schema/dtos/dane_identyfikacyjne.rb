# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Dane identyfikacyjne podmiotu - FA(3) format
      #
      # TPodmiot1 (seller): NIP + Nazwa (both required)
      # TPodmiot2 (buyer): choice (NIP | KodUE+NrVatUE | KodKraju+NrID | BrakID) + optional Nazwa
      class DaneIdentyfikacyjne < BaseDTO
        include XMLSerializable

        attr_reader :nip, :kod_ue, :nr_vat_ue, :kod_kraju, :nr_id, :brak_id, :nazwa

        # @param nazwa [String, nil] Nazwa/Imię i nazwisko (required for Podmiot1, optional for Podmiot2)
        # @param nip [String, nil] NIP (10 digits)
        # @param kod_ue [String, nil] Kod UE (2-letter country code for EU VAT)
        # @param nr_vat_ue [String, nil] Numer VAT UE (without country prefix)
        # @param kod_kraju [String, nil] Kod kraju for NrID
        # @param nr_id [String, nil] Other tax identifier
        # @param brak_id [Integer, nil] No identifier: 1 (used when buyer has no tax ID)
        def initialize(
          nazwa: nil,
          nip: nil,
          kod_ue: nil,
          nr_vat_ue: nil,
          kod_kraju: nil,
          nr_id: nil,
          brak_id: nil
        )
          @nazwa = nazwa
          @nip = nip
          @kod_ue = kod_ue
          @nr_vat_ue = nr_vat_ue
          @kod_kraju = kod_kraju
          @nr_id = nr_id
          @brak_id = brak_id

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          dane = doc.add_element("DaneIdentyfikacyjne")

          # Choice: NIP | (KodUE + NrVatUE) | (KodKraju + NrID) | BrakID
          if @nip
            add_element_if_present(dane, "NIP", @nip)
          elsif @kod_ue && @nr_vat_ue
            add_element_if_present(dane, "KodUE", @kod_ue)
            add_element_if_present(dane, "NrVatUE", @nr_vat_ue)
          elsif @nr_id
            add_element_if_present(dane, "KodKraju", @kod_kraju) if @kod_kraju
            add_element_if_present(dane, "NrID", @nr_id)
          elsif @brak_id
            add_element_if_present(dane, "BrakID", @brak_id)
          end

          # Optional Nazwa (required for Podmiot1, optional for Podmiot2)
          add_element_if_present(dane, "Nazwa", @nazwa) if @nazwa

          doc
        end

        def self.from_nokogiri(element)
          new(
            nip: text_at(element, "NIP"),
            kod_ue: text_at(element, "KodUE"),
            nr_vat_ue: text_at(element, "NrVatUE"),
            kod_kraju: text_at(element, "KodKraju"),
            nr_id: text_at(element, "NrID"),
            brak_id: text_at(element, "BrakID")&.to_i,
            nazwa: text_at(element, "Nazwa")
          )
        end

        private

        def validate!
          # Must have exactly one identifier
          identifiers = [@nip, (@kod_ue && @nr_vat_ue), @nr_id, @brak_id].compact
          raise ArgumentError, "Must specify exactly one identifier (NIP, KodUE+NrVatUE, NrID, or BrakID)" if identifiers.empty?

          # KodUE and NrVatUE must go together
          return unless (@kod_ue && !@nr_vat_ue) || (!@kod_ue && @nr_vat_ue)

          raise ArgumentError, "KodUE and NrVatUE must be specified together"
        end
      end
    end
  end
end
