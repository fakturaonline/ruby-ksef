# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Adres (address) - FA(3) format
      #
      # FA(3) používá zjednodušenou strukturu adresy:
      # - AdresL1: První řádek adresy (ulice + číslo)
      # - AdresL2: Druhý řádek adresy (PSČ + město)
      #
      # @example
      #   Adres.new(
      #     kod_kraju: "PL",
      #     adres_l1: "Testowa 1/10",
      #     adres_l2: "00-001 Warszawa"
      #   )
      class Adres < BaseDTO
        include XMLSerializable

        attr_reader :kod_kraju, :adres_l1, :adres_l2, :gln

        # @param kod_kraju [String] Kod kraju (ISO 3166-1 alpha-2), např. "PL", "CZ", "SK"
        # @param adres_l1 [String] První řádek adresy (max 512 znaků) - ulice, číslo domu, číslo bytu
        # @param adres_l2 [String, nil] Druhý řádek adresy (max 512 znaků) - PSČ, město
        # @param gln [String, nil] Global Location Number (13 znaků)
        def initialize(
          kod_kraju:,
          adres_l1:,
          adres_l2: nil,
          gln: nil
        )
          @kod_kraju = kod_kraju
          @adres_l1 = adres_l1
          @adres_l2 = adres_l2
          @gln = gln

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          adres = doc.add_element("Adres")

          # KodKraju - povinné
          add_element_if_present(adres, "KodKraju", @kod_kraju)

          # AdresL1 - povinné
          add_element_if_present(adres, "AdresL1", @adres_l1)

          # AdresL2 - volitelné
          add_element_if_present(adres, "AdresL2", @adres_l2) if @adres_l2

          # GLN - volitelné
          add_element_if_present(adres, "GLN", @gln) if @gln

          doc
        end

        def self.from_nokogiri(element)
          new(
            kod_kraju: text_at(element, "KodKraju"),
            adres_l1: text_at(element, "AdresL1"),
            adres_l2: text_at(element, "AdresL2"),
            gln: text_at(element, "GLN")
          )
        end

        # Helper metoda pro vytvoření adresy z FA(2) formátu
        # Zachovává zpětnou kompatibilitu API
        def self.from_fa2_format(
          kod_kraju:,
          ulica: nil,
          nr_domu: nil,
          nr_lokalu: nil,
          miejscowosc: nil,
          kod_pocztowy: nil,
          **_ignored
        )
          # Sestavit AdresL1 z ulice a čísel
          adres_parts = [ulica, nr_domu].compact
          adres_parts << "/#{nr_lokalu}" if nr_lokalu
          adres_l1 = adres_parts.join(" ").strip

          # Sestavit AdresL2 z PSČ a města
          adres_l2_parts = [kod_pocztowy, miejscowosc].compact
          adres_l2 = adres_l2_parts.join(" ").strip
          adres_l2 = nil if adres_l2.empty?

          new(
            kod_kraju: kod_kraju,
            adres_l1: adres_l1.empty? ? miejscowosc || "Unknown" : adres_l1,
            adres_l2: adres_l2
          )
        end

        private

        def validate!
          raise ArgumentError, "kod_kraju is required" if @kod_kraju.blank?
          raise ArgumentError, "adres_l1 is required" if @adres_l1.blank?
          raise ArgumentError, "adres_l1 is too long (max 512 chars)" if @adres_l1.length > 512
          raise ArgumentError, "adres_l2 is too long (max 512 chars)" if @adres_l2 && @adres_l2.length > 512
          raise ArgumentError, "GLN must be 13 characters" if @gln && @gln.length != 13
        end
      end
    end
  end
end
