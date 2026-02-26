# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Rodzaj faktury
      class RodzajFaktury
        VAT       = "VAT"
        KOR       = "KOR" # FA(3): faktura korygująca
        KOR_ZAL   = "KOR_ZAL"  # FA(3): korekta faktury zaliczkowej
        KOR_ROZ   = "KOR_ROZ"  # FA(3): korekta faktury rozliczeniowej
        ZALICZKOWA = "ZAL"
        ROZ       = "ROZ"
        UPR       = "UPR"

        # Backward-compat alias — FA(2) used "KOREKTA", FA(3) uses "KOR"
        KOREKTA   = KOR

        attr_reader :value

        def initialize(value = VAT)
          @value = value
          validate!
        end

        def to_s
          @value
        end

        private

        def validate!
          valid_types = [VAT, KOR, KOR_ZAL, KOR_ROZ, ZALICZKOWA, ROZ, UPR]
          return if valid_types.include?(@value)

          raise ArgumentError, "Invalid invoice type: #{@value}. Valid: #{valid_types.join(", ")}"
        end
      end
    end
  end
end
