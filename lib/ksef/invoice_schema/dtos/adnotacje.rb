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

        attr_reader :p_16, :p_17, :p_18, :p_18a, :p_19n, :p_20, :p_22n, :p_23,
                    :p_pmarzy_n, :p_pmarzy_m, :p_pmarzy_t

        # @param p_16 [Integer] Metoda kasowa: 1=ano, 2=ne (default: 2)
        # @param p_17 [Integer] Samofakturowanie: 1=ano, 2=ne (default: 2)
        # @param p_18 [Integer] Odwrotné obciążení: 1=ano, 2=ne (default: 2)
        # @param p_18a [Integer] Mechanizm podzielonej płatności: 1=ano, 2=ne (default: 2)
        # Zwolnienie choice — exactly one must be set:
        # @param p_19n [Integer, nil] Není zwolnienie: 1 (default — normal VAT invoice)
        # @param p_20 [Integer, nil] Zwolnienie podmiotowe art. 113: 1 (non-VAT-registered seller)
        # @param p_22n [Integer] Nejsou nové vozidla: 1 (default)
        # @param p_23 [Integer] Není procedura uproszczona: 2 (default)
        # PMarzy choice — exactly one must be set:
        # @param p_pmarzy_n [Integer, nil] Není marže: 1 (default — not margin scheme)
        # @param p_pmarzy_m [Integer, nil] Marže art. 119 (cestovní kancelář): 1
        # @param p_pmarzy_t [Integer, nil] Marže art. 120 (použité zboží, umění, sběratelství): 1
        def initialize(
          p_16: 2,
          p_17: 2,
          p_18: 2,
          p_18a: 2,
          p_19n: nil,
          p_20: nil,
          p_22n: 1,
          p_23: 2,
          p_pmarzy_n: nil,
          p_pmarzy_m: nil,
          p_pmarzy_t: nil
        )
          @p_16 = p_16 || 2
          @p_17 = p_17 || 2
          @p_18 = p_18 || 2
          @p_18a = p_18a || 2
          @p_19n = p_19n
          @p_20 = p_20
          # Default to P_19N=1 (normal VAT) when no Zwolnienie option specified
          @p_19n = 1 if @p_19n.nil? && @p_20.nil?
          @p_22n = p_22n || 1
          @p_23 = p_23 || 2
          @p_pmarzy_n = p_pmarzy_n
          @p_pmarzy_m = p_pmarzy_m
          @p_pmarzy_t = p_pmarzy_t
          # Default to P_PMarzyN=1 (not margin) when none explicitly specified
          @p_pmarzy_n = 1 if @p_pmarzy_n.nil? && @p_pmarzy_m.nil? && @p_pmarzy_t.nil?

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

          # 5. Zwolnienie - POVINNÉ! (choice: P_19N nebo P_20 nebo P_21)
          zwolnienie = adnotacje.add_element("Zwolnienie")
          if @p_20
            add_element_if_present(zwolnienie, "P_20", @p_20)
          else
            add_element_if_present(zwolnienie, "P_19N", @p_19n)
          end

          # 6. NoweSrodkiTransportu - POVINNÉ! (choice: P_22+... nebo P_22N)
          nst = adnotacje.add_element("NoweSrodkiTransportu")
          add_element_if_present(nst, "P_22N", @p_22n)

          # 7. P_23 - Procedura uproszczona
          add_element_if_present(adnotacje, "P_23", @p_23)

          # 8. PMarzy - POVINNÉ! (choice: P_PMarzyN / P_PMarzyM / P_PMarzyT)
          pmarzy = adnotacje.add_element("PMarzy")
          if @p_pmarzy_m
            add_element_if_present(pmarzy, "P_PMarzyM", @p_pmarzy_m)
          elsif @p_pmarzy_t
            add_element_if_present(pmarzy, "P_PMarzyT", @p_pmarzy_t)
          else
            add_element_if_present(pmarzy, "P_PMarzyN", @p_pmarzy_n)
          end

          doc
        end

        def self.from_nokogiri(element) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
          zwolnienie_el = element.at_xpath("Zwolnienie")
          pmarzy_el = element.at_xpath("PMarzy")
          new(
            p_16: text_at(element, "P_16")&.to_i || 2,
            p_17: text_at(element, "P_17")&.to_i || 2,
            p_18: text_at(element, "P_18")&.to_i || 2,
            p_18a: text_at(element, "P_18A")&.to_i || 2,
            p_19n: text_at(zwolnienie_el, "P_19N")&.to_i,
            p_20: text_at(zwolnienie_el, "P_20")&.to_i,
            p_22n: text_at(element.at_xpath("NoweSrodkiTransportu"), "P_22N")&.to_i || 1,
            p_23: text_at(element, "P_23")&.to_i || 2,
            p_pmarzy_n: text_at(pmarzy_el, "P_PMarzyN")&.to_i,
            p_pmarzy_m: text_at(pmarzy_el, "P_PMarzyM")&.to_i,
            p_pmarzy_t: text_at(pmarzy_el, "P_PMarzyT")&.to_i
          )
        end

        private

        def validate!
          raise ArgumentError, "p_16 is required and must be 1 or 2" unless [1, 2].include?(@p_16)
          raise ArgumentError, "p_17 is required and must be 1 or 2" unless [1, 2].include?(@p_17)
          raise ArgumentError, "p_18 is required and must be 1 or 2" unless [1, 2].include?(@p_18)
          raise ArgumentError, "p_18a is required and must be 1 or 2" unless [1, 2].include?(@p_18a)
          raise ArgumentError, "p_22n is required and must be 1" unless @p_22n == 1
          raise ArgumentError, "p_23 is required and must be 1 or 2" unless [1, 2].include?(@p_23)

          zwolnienie_set = [@p_19n, @p_20].count { |v| v == 1 }
          raise ArgumentError, "Exactly one Zwolnienie option (p_19n or p_20) must be set to 1" unless zwolnienie_set == 1

          pmarzy_set = [@p_pmarzy_n, @p_pmarzy_m, @p_pmarzy_t].count { |v| v == 1 }
          raise ArgumentError, "Exactly one PMarzy flag must be set to 1" unless pmarzy_set == 1
        end
      end
    end
  end
end
