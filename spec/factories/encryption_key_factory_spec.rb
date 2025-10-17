# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Factories::EncryptionKeyFactory do
  describe ".generate_random" do
    it "generates an EncryptionKey object" do
      result = described_class.generate_random

      expect(result).to be_a(KSEF::ValueObjects::EncryptionKey)
    end

    it "generates 256-bit key" do
      result = described_class.generate_random

      expect(result.key.bytesize).to eq(32) # 256 bits = 32 bytes
    end

    it "generates 128-bit IV" do
      result = described_class.generate_random

      expect(result.iv.bytesize).to eq(16) # 128 bits = 16 bytes
    end

    it "generates random key each time" do
      key1 = described_class.generate_random
      key2 = described_class.generate_random

      expect(key1.key).not_to eq(key2.key)
      expect(key1.iv).not_to eq(key2.iv)
    end

    it "generates cryptographically secure random data" do
      keys = Array.new(10) { described_class.generate_random }

      # All keys should be unique
      unique_keys = keys.map(&:key).uniq
      expect(unique_keys.length).to eq(10)

      # All IVs should be unique
      unique_ivs = keys.map(&:iv).uniq
      expect(unique_ivs.length).to eq(10)
    end

    it "generates keys suitable for AES-256-CBC" do
      encryption_key = described_class.generate_random

      # Test that key can be used for encryption
      cipher = OpenSSL::Cipher.new("AES-256-CBC")
      cipher.encrypt
      cipher.key = encryption_key.key
      cipher.iv = encryption_key.iv

      test_data = "Test data for encryption"
      encrypted = cipher.update(test_data) + cipher.final

      # Decrypt to verify
      decipher = OpenSSL::Cipher.new("AES-256-CBC")
      decipher.decrypt
      decipher.key = encryption_key.key
      decipher.iv = encryption_key.iv

      decrypted = decipher.update(encrypted) + decipher.final

      expect(decrypted).to eq(test_data)
    end

    it "key is binary data" do
      result = described_class.generate_random

      expect(result.key.encoding).to eq(Encoding::BINARY)
      expect(result.iv.encoding).to eq(Encoding::BINARY)
    end

    it "generates keys with high entropy" do
      # Generate multiple keys and check they're not predictable
      keys = Array.new(100) { described_class.generate_random.key }

      # Count unique bytes in first position
      first_bytes = keys.map { |k| k[0].ord }
      unique_first_bytes = first_bytes.uniq.length

      # With 100 samples, we should see good distribution (at least 30 unique values)
      expect(unique_first_bytes).to be >= 30
    end

    context "integration with EncryptDocument action" do
      it "generates keys compatible with encryption action" do
        encryption_key = described_class.generate_random
        test_xml = '<?xml version="1.0"?><Test>Data</Test>'

        # Create encryption action
        encrypt_action = KSEF::Actions::EncryptDocument.new(encryption_key)

        # Encrypt
        encrypted = encrypt_action.call(test_xml)

        expect(encrypted).to be_a(String)
        expect(encrypted).not_to eq(test_xml)

        # Decrypt to verify
        decrypt_action = KSEF::Actions::DecryptDocument.new(encryption_key)
        decrypted = decrypt_action.call(encrypted)

        expect(decrypted).to eq(test_xml)
      end
    end

    context "performance" do
      it "generates keys quickly" do
        start_time = Time.now

        100.times { described_class.generate_random }

        elapsed = Time.now - start_time

        # Should generate 100 keys in under 1 second
        expect(elapsed).to be < 1.0
      end
    end

    context "key format" do
      it "key can be base64 encoded" do
        encryption_key = described_class.generate_random

        key_base64 = Base64.strict_encode64(encryption_key.key)
        iv_base64 = Base64.strict_encode64(encryption_key.iv)

        expect(key_base64).to be_a(String)
        expect(iv_base64).to be_a(String)

        # Verify decoding works
        decoded_key = Base64.decode64(key_base64)
        decoded_iv = Base64.decode64(iv_base64)

        expect(decoded_key).to eq(encryption_key.key)
        expect(decoded_iv).to eq(encryption_key.iv)
      end

      it "key can be hex encoded" do
        encryption_key = described_class.generate_random

        key_hex = encryption_key.key.unpack1("H*")
        iv_hex = encryption_key.iv.unpack1("H*")

        expect(key_hex.length).to eq(64) # 32 bytes = 64 hex chars
        expect(iv_hex.length).to eq(32)  # 16 bytes = 32 hex chars

        # Verify decoding works
        decoded_key = [key_hex].pack("H*")
        decoded_iv = [iv_hex].pack("H*")

        expect(decoded_key).to eq(encryption_key.key)
        expect(decoded_iv).to eq(encryption_key.iv)
      end
    end
  end
end
