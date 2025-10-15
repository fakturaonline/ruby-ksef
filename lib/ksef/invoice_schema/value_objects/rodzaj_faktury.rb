# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Rodzaj faktury
      class RodzajFaktury
        VAT = 'VAT'
        KOREKTA = 'KOREKTA'
        ZALICZKOWA = 'ZAL'
        ROZ = 'ROZ'
        UPR = 'UPR'

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
          valid_types = [VAT, KOREKTA, ZALICZKOWA, ROZ, UPR]
          unless valid_types.include?(@value)
            raise ArgumentError, "Invalid invoice type: #{@value}"
          end
        end
      end
    end
  end
end
