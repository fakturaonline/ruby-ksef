# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Adnotacje - adnotace na faktuře
      class Adnotacje < BaseDTO
        include XMLSerializable

        attr_reader :p_16, :p_17, :p_18, :p_18a, :zwolnienie, :nowesrodkitransportu, :marza, :samofakturowanie

        # @param p_16 [String, nil] Adnotacja 16
        # @param p_17 [String, nil] Adnotacja 17
        # @param p_18 [String, nil] Adnotacja 18
        # @param p_18a [String, nil] Adnotacja 18A
        # @param zwolnienie [String, nil] Zwolnienie z VAT
        # @param nowesrodkitransportu [Boolean] Nowe środki transportu
        # @param marza [Boolean] Procedura marży
        # @param samofakturowanie [Boolean] Samofakturowanie
        def initialize(
          p_16: nil,
          p_17: nil,
          p_18: nil,
          p_18a: nil,
          zwolnienie: nil,
          nowesrodkitransportu: false,
          marza: false,
          samofakturowanie: false
        )
          @p_16 = p_16
          @p_17 = p_17
          @p_18 = p_18
          @p_18a = p_18a
          @zwolnienie = zwolnienie
          @nowesrodkitransportu = nowesrodkitransportu
          @marza = marza
          @samofakturowanie = samofakturowanie
        end

        def to_rexml
          doc = REXML::Document.new
          adnotacje = doc.add_element('Adnotacje')

          add_element_if_present(adnotacje, 'P_16', @p_16)
          add_element_if_present(adnotacje, 'P_17', @p_17)
          add_element_if_present(adnotacje, 'P_18', @p_18)
          add_element_if_present(adnotacje, 'P_18A', @p_18a)
          add_element_if_present(adnotacje, 'Zwolnienie', @zwolnienie)
          add_element_if_present(adnotacje, 'NoweSrodkiTransportu', '1') if @nowesrodkitransportu
          add_element_if_present(adnotacje, 'Marza', '1') if @marza
          add_element_if_present(adnotacje, 'Samofakturowanie', '1') if @samofakturowanie

          doc
        end
      end
    end
  end
end
