# frozen_string_literal: true

module KSEF
  module Actions
    # Action for converting ECDSA DER signature to raw format (r||s)
    class ConvertEcdsaDerToRaw
      # Convert ECDSA DER to raw (r||s)
      # @param der [String] DER-encoded signature
      # @param key_size [Integer] Key size in bytes (default: 32 for P-256)
      # @return [String] Raw signature (r||s concatenated)
      def call(der, key_size: 32)
        data = der.bytes
        offset = 0

        # Check for SEQUENCE tag
        raise ArgumentError, "Invalid DER: no SEQUENCE" unless data[offset] == 0x30

        offset += 1

        # Read sequence length
        seq_len = data[offset]
        offset += 1
        if seq_len.anybits?(0x80)
          len_bytes = seq_len & 0x7F
          seq_len = 0
          len_bytes.times do
            seq_len = (seq_len << 8) | data[offset]
            offset += 1
          end
        end

        # Read INTEGER r
        raise ArgumentError, "Invalid DER: expected INTEGER (r)" unless data[offset] == 0x02

        offset += 1

        r_len = data[offset]
        offset += 1
        r = data[offset, r_len].pack("C*")
        offset += r_len

        # Read INTEGER s
        raise ArgumentError, "Invalid DER: expected INTEGER (s)" unless data[offset] == 0x02

        offset += 1

        s_len = data[offset]
        offset += 1
        s = data[offset, s_len].pack("C*")

        # Pad to key size (remove leading zeros and pad to fixed length)
        r = r.bytes.drop_while(&:zero?).pack("C*").rjust(key_size, "\x00")
        s = s.bytes.drop_while(&:zero?).pack("C*").rjust(key_size, "\x00")

        r + s
      end
    end
  end
end
