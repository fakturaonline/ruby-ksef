# frozen_string_literal: true

RSpec.describe KSEF::Actions::EncryptDocument do
  let(:encryption_key) { KSEF::ValueObjects::EncryptionKey.random }
  let(:document) { "<?xml version=\"1.0\"?><Invoice>Test</Invoice>" }

  describe "#call" do
    it "encrypts document" do
      encryptor = described_class.new(encryption_key)
      encrypted = encryptor.call(document)

      expect(encrypted).not_to eq document
      expect(encrypted.encoding).to eq Encoding::BINARY
    end

    it "produces decryptable output" do
      encryptor = described_class.new(encryption_key)
      encrypted = encryptor.call(document)

      decryptor = KSEF::Actions::DecryptDocument.new(encryption_key)
      decrypted = decryptor.call(encrypted)

      expect(decrypted).to eq document
    end
  end
end
