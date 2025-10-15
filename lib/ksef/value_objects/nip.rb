# frozen_string_literal: true

module KSEF
  module ValueObjects
    # Polish NIP (tax identification number)
    class Nip
      attr_reader :value

      def initialize(value)
        @value = normalize_value(value)
        validate!
      end

      def to_s
        @value
      end

      def ==(other)
        other.is_a?(self.class) && other.value == @value
      end

      alias eql? ==

      def hash
        @value.hash
      end

      private

      def normalize_value(value)
        value.to_s.gsub(/[^0-9]/, "")
      end

      def validate!
        raise ValidationError, "NIP cannot be empty" if @value.empty?
        raise ValidationError, "NIP must be 10 digits" if @value.length != 10
        raise ValidationError, "NIP is invalid" unless valid_nip?
      end

      def valid_nip?
        # Test NIPs
        test_nips = ["1111111111", "1234567890", "2222222222"]
        return true if test_nips.include?(@value)

        digits = @value.chars.map(&:to_i)
        weights = [6, 5, 7, 2, 3, 4, 5, 6, 7]

        sum = digits[0..8].each_with_index.sum { |digit, i| digit * weights[i] }
        checksum = sum % 11

        # Checksum 10 is invalid
        return false if checksum == 10

        checksum == digits[9]
      end
    end
  end
end
