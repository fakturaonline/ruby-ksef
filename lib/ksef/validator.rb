# frozen_string_literal: true

module KSEF
  # Validator module for data validation
  module Validator
    # Validate values against rules
    # @param values [Object, Array, Hash] Values to validate
    # @param rules [Array<AbstractRule>, Hash] Rules to apply
    # @return [void]
    # @raise [ArgumentError] If validation fails
    def self.validate(values, rules)
      values_array = values.is_a?(Hash) ? values : Array(values)

      if values.is_a?(Hash)
        # Hash of attribute => value
        values.each do |attribute, value|
          next if value.nil? # Skip optional values

          attribute_rules = rules[attribute] || rules[attribute.to_s] || []
          attribute_rules = Array(attribute_rules)

          attribute_rules.each do |rule|
            rule.call(value, attribute: attribute)
          end
        end
      else
        # Array or single value
        rules_array = Array(rules)

        Array(values).each do |value|
          next if value.nil?

          rules_array.each do |rule|
            rule.call(value)
          end
        end
      end
    end
  end
end
