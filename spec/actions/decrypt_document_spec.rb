# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::DecryptDocument do
  let(:encryption_key) { KSEF::ValueObjects::EncryptionKey.random }
  let(:encryptor) { KSEF::Actions::EncryptDocument.new(encryption_key) }
  let(:decryptor) { described_class.new(encryption_key) }

  describe "#call" do
    it "decrypts previously encrypted data" do
      original = "Test invoice XML content"
      encrypted = encryptor.call(original)
      decrypted = decryptor.call(encrypted)

      expect(decrypted).to eq(original)
    end

    it "handles binary encrypted data" do
      original = "Binary test data with special chars: ąćęłńóśźż"
      encrypted = encryptor.call(original)
      decrypted = decryptor.call(encrypted)

      expect(decrypted.force_encoding("UTF-8")).to eq(original)
    end

    it "handles large documents" do
      original = "X" * 100_000 # 100KB document
      encrypted = encryptor.call(original)
      decrypted = decryptor.call(encrypted)

      expect(decrypted).to eq(original)
      expect(decrypted.size).to eq(100_000)
    end

    it "raises error with wrong key" do
      original = "Test data"
      encrypted = encryptor.call(original)

      wrong_key = KSEF::ValueObjects::EncryptionKey.random
      wrong_decryptor = described_class.new(wrong_key)

      expect { wrong_decryptor.call(encrypted) }.to raise_error(OpenSSL::Cipher::CipherError)
    end
  end

  describe "integration with EncryptDocument" do
    it "performs round-trip encryption/decryption" do
      test_cases = [
        "Simple text",
        "Polskie znaki: ąćęłńóśźż ĄĆĘŁŃÓŚŹŻ",
        "<xml><node>Value</node></xml>",
        "Numbers: 1234567890",
        "Special: !@#$%^&*()",
        ""
      ]

      test_cases.each do |original|
        encrypted = encryptor.call(original)
        decrypted = decryptor.call(encrypted).force_encoding("UTF-8")
        expect(decrypted).to eq(original), "Failed for: #{original.inspect}"
      end
    end
  end
end
