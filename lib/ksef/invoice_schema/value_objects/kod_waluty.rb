# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Kod waluty (ISO 4217)
      class KodWaluty
        attr_reader :value

        def initialize(value)
          @value = value.to_s.upcase
          validate!
        end

        def to_s
          @value
        end

        private

        def validate!
          # Basic validation - could be extended with full currency list
          unless @value.match?(/^[A-Z]{3}$/)
            raise ArgumentError, "Invalid currency code: #{@value}"
          end
        end
      end
    end
  end
end
