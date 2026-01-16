# frozen_string_literal: true

module KSEF
  module ValueObjects
    # Context identifier for authentication
    # Supports multiple types: Nip, InternalId, PeppolId (RC5+)
    class ContextIdentifier
      VALID_TYPES = %w[Nip InternalId PeppolId].freeze

      attr_reader :type, :value

      # @param type [String] Type of identifier (Nip, InternalId, PeppolId)
      # @param value [String] Identifier value
      def initialize(type:, value:)
        @type = type
        @value = value
        validate!
      end

      # Convert to hash for API requests
      def to_h
        {
          type: @type,
          value: @value
        }
      end

      # Build from NIP value object
      # @param nip [KSEF::ValueObjects::NIP] NIP value object
      # @return [ContextIdentifier] Context identifier with type Nip
      def self.from_nip(nip)
        new(type: "Nip", value: nip.value)
      end

      # Build from internal ID
      # @param internal_id [String] Internal identifier
      # @return [ContextIdentifier] Context identifier with type InternalId
      def self.from_internal_id(internal_id)
        new(type: "InternalId", value: internal_id)
      end

      # Build from Peppol ID
      # @param peppol_id [String] Peppol identifier
      # @return [ContextIdentifier] Context identifier with type PeppolId
      def self.from_peppol_id(peppol_id)
        new(type: "PeppolId", value: peppol_id)
      end

      def to_s
        "#{@type}:#{@value}"
      end

      private

      def validate!
        unless VALID_TYPES.include?(@type)
          raise ArgumentError, "Invalid context identifier type: #{@type}. Valid types: #{VALID_TYPES.join(', ')}"
        end

        raise ArgumentError, "Context identifier value cannot be empty" if @value.nil? || @value.to_s.empty?
      end
    end
  end
end
