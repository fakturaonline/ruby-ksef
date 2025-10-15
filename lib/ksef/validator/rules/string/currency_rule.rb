# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module String
        # Validation rule for ISO 4217 currency codes
        class CurrencyRule < AbstractRule
          # ISO 4217 currency codes (common subset)
          VALID_CURRENCIES = %w[
            AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BRL BSD BTN BWP BYN BZD
            CAD CDF CHF CLP CNY COP CRC CUC CUP CVE CZK DJF DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GGP GHS
            GIP GMD GNF GTQ GYD HKD HNL HRK HTG HUF IDR ILS IMP INR IQD IRR ISK JEP JMD JOD JPY KES KGS KHR KMF
            KPW KRW KWD KYD KZT LAK LBP LKR LRD LSL LYD MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MYR MZN
            NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SDG SEK SGD
            SHP SLE SLL SOS SPL SRD STN SVC SYP SZL THB TJS TMT TND TOP TRY TTD TVD TWD TZS UAH UGX USD UYU UZS
            VEF VES VND VUV WST XAF XCD XDR XOF XPF YER ZAR ZMW ZWD
          ].freeze

          # Validate currency code
          # @param value [String] Currency code to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If currency code is invalid
          def call(value, attribute: nil)
            unless VALID_CURRENCIES.include?(value.to_s.upcase)
              raise ArgumentError, format_message(
                "Invalid currency code. Must be a valid ISO 4217 code.",
                attribute
              )
            end
          end
        end
      end
    end
  end
end
