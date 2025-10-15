# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Date
        # Validation rule for dates that must be before a given date
        class BeforeRule < AbstractRule
          # @param before_date [Date, Time, String] Date that value must be before
          def initialize(before_date)
            @before_date = parse_date(before_date)
          end

          # Validate date is before reference date
          # @param value [Date, Time, String] Date to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If date is not before reference date
          def call(value, attribute: nil)
            value_date = parse_date(value)

            unless value_date < @before_date
              raise ArgumentError, format_message(
                "Date must be before #{@before_date}.",
                attribute
              )
            end
          end

          private

          def parse_date(value)
            case value
            when ::Date, ::Time, ::DateTime
              value
            when String
              ::Date.parse(value)
            else
              raise ArgumentError, "Unable to parse date from #{value.class}"
            end
          end
        end
      end
    end
  end
end
