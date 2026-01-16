# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Adnotacje - adnotace na faktuře - FA(3) format
      #
      # FA(3) vyžaduje VŠECHNY elementy v přesném pořadí, i když jsou volitelné!
      # Pro běžnou fakturu s DPH posíláme všechny *N elementy (negace):
      # - P_16, P_17, P_18, P_18A (všechny=2 pro běžnou fakturu)
      # - Zwolnienie/P_19N=1 (není zwolnění)
      # - NoweSrodkiTransportu/P_22N=1 (nejsou nová vozidla)
      # - P_23=2 (není procedura uproszczona)
      # - PMarzy/P_PMarzyN=1 (není marže)
      class Adnotacje < BaseDTO
        include XMLSerializable

        attr_reader :p_16, :p_17, :p_18, :p_18a, :p_19n, :p_22n, :p_23, :p_pmarzy_n

        # @param p_16 [Integer] Metoda kasowa: 1=ano, 2=ne (default: 2)
        # @param p_17 [Integer] Samofakturowanie: 1=ano, 2=ne (default: 2)
        # @param p_18 [Integer] Odwrotné obciążení: 1=ano, 2=ne (default: 2)
        # @param p_18a [Integer] Mechanizm podzielonej płatności: 1=ano, 2=ne (default: 2)
        # @param p_19n [Integer] Není zwolnienie: 1 (default for normal VAT)
        # @param p_22n [Integer] Nejsou nové vozidla: 1 (default)
        # @param p_23 [Integer] Není procedura uproszczona: 2 (default)
        # @param p_pmarzy_n [Integer] Není marže: 1 (default)
        def initialize(
          p_16: 2,        # Není metoda kasowa
          p_17: 2,        # Není samofakturowanie
          p_18: 2,        # Není odwrotné obciążení
          p_18a: 2,       # Není split payment
          p_19n: 1,       # Není zwolnienie (normal VAT)
          p_22n: 1,       # Nejsou nové vozidla
          p_23: 2,        # Není procedura uproszczona
          p_pmarzy_n: 1   # Není marže
        )
          @p_16 = p_16 || 2
          @p_17 = p_17 || 2
          @p_18 = p_18 || 2
          @p_18a = p_18a || 2
          @p_19n = p_19n || 1
          @p_22n = p_22n || 1
          @p_23 = p_23 || 2
          @p_pmarzy_n = p_pmarzy_n || 1

          validate!
        end

        def to_rexml
          doc = REXML::Document.new
          adnotacje = doc.add_element("Adnotacje")

          # FA(3): VŠECHNY elementy v PŘESNÉM pořadí!

          # 1. P_16 - Metoda kasowa
          add_element_if_present(adnotacje, "P_16", @p_16)

          # 2. P_17 - Samofakturowanie
          add_element_if_present(adnotacje, "P_17", @p_17)

          # 3. P_18 - Odwrotne obciążenie
          add_element_if_present(adnotacje, "P_18", @p_18)

          # 4. P_18A - Mechanizm podzielonej płatności
          add_element_if_present(adnotacje, "P_18A", @p_18a)

          # 5. Zwolnienie - POVINNÉ! (choice: P_19+... nebo P_19N)
          zwolnienie = adnotacje.add_element("Zwolnienie")
          add_element_if_present(zwolnienie, "P_19N", @p_19n)

          # 6. NoweSrodkiTransportu - POVINNÉ! (choice: P_22+... nebo P_22N)
          nst = adnotacje.add_element("NoweSrodkiTransportu")
          add_element_if_present(nst, "P_22N", @p_22n)

          # 7. P_23 - Procedura uproszczona
          add_element_if_present(adnotacje, "P_23", @p_23)

          # 8. PMarzy - POVINNÉ! (choice: P_PMarzy+... nebo P_PMarzyN)
          pmarzy = adnotacje.add_element("PMarzy")
          add_element_if_present(pmarzy, "P_PMarzyN", @p_pmarzy_n)

          doc
        end

        def self.from_nokogiri(element)
          new(
            p_16: text_at(element, "P_16")&.to_i || 2,
            p_17: text_at(element, "P_17")&.to_i || 2,
            p_18: text_at(element, "P_18")&.to_i || 2,
            p_18a: text_at(element, "P_18A")&.to_i || 2,
            p_19n: text_at(element.at_xpath("Zwolnienie"), "P_19N")&.to_i || 1,
            p_22n: text_at(element.at_xpath("NoweSrodkiTransportu"), "P_22N")&.to_i || 1,
            p_23: text_at(element, "P_23")&.to_i || 2,
            p_pmarzy_n: text_at(element.at_xpath("PMarzy"), "P_PMarzyN")&.to_i || 1
          )
        end

        private

        def validate!
          raise ArgumentError, "p_16 is required and must be 1 or 2" unless [1, 2].include?(@p_16)
          raise ArgumentError, "p_17 is required and must be 1 or 2" unless [1, 2].include?(@p_17)
          raise ArgumentError, "p_18 is required and must be 1 or 2" unless [1, 2].include?(@p_18)
          raise ArgumentError, "p_18a is required and must be 1 or 2" unless [1, 2].include?(@p_18a)
          raise ArgumentError, "p_19n is required and must be 1" unless @p_19n == 1
          raise ArgumentError, "p_22n is required and must be 1" unless @p_22n == 1
          raise ArgumentError, "p_23 is required and must be 1 or 2" unless [1, 2].include?(@p_23)
          raise ArgumentError, "p_pmarzy_n is required and must be 1" unless @p_pmarzy_n == 1
        end
      end
    end
  end
end
