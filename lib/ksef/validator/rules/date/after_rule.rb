# frozen_string_literal: true

module KSEF
  module Validator
    module Rules
      module Date
        # Validation rule for dates that must be after a given date
        class AfterRule < AbstractRule
          # @param after_date [Date, Time, String] Date that value must be after
          def initialize(after_date)
            @after_date = parse_date(after_date)
          end

          # Validate date is after reference date
          # @param value [Date, Time, String] Date to validate
          # @param attribute [String, nil] Optional attribute name
          # @return [void]
          # @raise [ArgumentError] If date is not after reference date
          def call(value, attribute: nil)
            value_date = parse_date(value)

            return if value_date > @after_date

            raise ArgumentError, format_message(
              "Date must be after #{@after_date}.",
              attribute
            )
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
