# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Base class for all invoice DTOs
    class BaseDTO
      include XMLSerializable
      extend Parser

      # Initialize with hash or keyword arguments
      def initialize(**attributes)
        attributes.each do |key, value|
          instance_variable_set("@#{key}", value)
          self.class.attr_reader(key) unless respond_to?(key)
        end
      end

      # Convert to hash
      # @return [Hash] Hash representation
      def to_h
        instance_variables.each_with_object({}) do |var, hash|
          key = var.to_s.delete("@").to_sym
          value = instance_variable_get(var)
          hash[key] = value.respond_to?(:to_h) ? value.to_h : value
        end
      end

      class << self
        include Parser
      end
    end
  end
end
