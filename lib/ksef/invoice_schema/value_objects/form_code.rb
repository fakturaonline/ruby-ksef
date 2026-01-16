# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module ValueObjects
      # Kod formularza faktury
      class FormCode
        FA2 = "FA(2)"
        FA3 = "FA(3)"
        PEF = "PEF (3)"
        PEF_KOR = "PEF_KOR (3)"

        attr_reader :value

        def initialize(value = 3)  # Default FA(3) for KSeF 2.0 API
          # Accept integer or string
          @value = case value
                   when 2, "2", FA2 then FA2
                   when 3, "3", FA3 then FA3
                   when "PEF", PEF then PEF
                   when "PEF_KOR", PEF_KOR then PEF_KOR
                   else value
                   end
          validate!
        end

        def to_s
          @value
        end

        def schema_version
          "1-0E" # Same version for all form codes
        end

        def wariant_formularza
          match = @value.match(/\((\d+)\)/)
          match ? match[1].to_i : 3
        end

        def target_namespace
          "http://crd.gov.pl/wzor/2023/06/29/12648/"
        end

        private

        def validate!
          return if [FA2, FA3, PEF, PEF_KOR].include?(@value)

          raise ArgumentError, "Invalid form code: #{@value}. Valid codes: FA(2), FA(3), PEF (3), PEF_KOR (3)"
        end
      end
    end
  end
end
