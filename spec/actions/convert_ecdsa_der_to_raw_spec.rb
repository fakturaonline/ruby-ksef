# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::ConvertEcdsaDerToRaw do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:ec_key) { OpenSSL::PKey::EC.generate("prime256v1") }
    let(:test_data) { "Test message for signing" }
    let(:signature) { ec_key.sign("SHA256", test_data) }

    context "with valid ECDSA DER signature" do
      it "converts to raw format (r||s)" do
        result = action.call(signature)

        expect(result).to be_a(String)
        expect(result.bytesize).to eq(64) # 32 bytes r + 32 bytes s for P-256
      end

      it "produces consistent results" do
        result1 = action.call(signature)
        result2 = action.call(signature)

        expect(result1).to eq(result2)
      end
    end

    context "with different key sizes" do
      it "handles P-256 (32 bytes)" do
        result = action.call(signature, key_size: 32)
        expect(result.bytesize).to eq(64)
      end

      it "handles custom key sizes" do
        # For testing purposes with P-256 signature
        result = action.call(signature, key_size: 48)
        expect(result.bytesize).to eq(96) # 48 * 2
      end
    end

    context "with invalid DER data" do
      it "raises error for missing SEQUENCE tag" do
        invalid_der = "\x00\x00\x00\x00"

        expect do
          action.call(invalid_der)
        end.to raise_error(ArgumentError, /Invalid DER: no SEQUENCE/)
      end

      it "raises error for missing INTEGER r" do
        invalid_der = "\x30\x06\x00\x00\x00\x00\x00\x00"

        expect do
          action.call(invalid_der)
        end.to raise_error(ArgumentError, /Invalid DER: expected INTEGER \(r\)/)
      end

      it "raises error for missing INTEGER s" do
        # SEQUENCE with just r INTEGER
        invalid_der = "\x30\x04\x02\x01\x00\x00"

        expect do
          action.call(invalid_der)
        end.to raise_error(ArgumentError, /Invalid DER: expected INTEGER \(s\)/)
      end
    end

    context "with real ECDSA signature" do
      it "can verify signature after conversion" do
        raw_sig = action.call(signature)

        # Convert back to DER for verification
        r = raw_sig[0, 32].unpack1("H*").to_i(16)
        s = raw_sig[32, 32].unpack1("H*").to_i(16)

        # Verify original signature is valid
        expect(ec_key.verify("SHA256", signature, test_data)).to be true
      end
    end

    context "with signature containing leading zeros" do
      it "pads correctly to key size" do
        # Create a simple DER with small values that need padding
        # SEQUENCE { INTEGER r, INTEGER s }
        der = [
          0x30, 0x08, # SEQUENCE of length 8
          0x02, 0x01, 0x05, # INTEGER r = 5
          0x02, 0x01, 0x0a # INTEGER s = 10
        ].pack("C*")

        result = action.call(der, key_size: 32)

        expect(result.bytesize).to eq(64)
        # r should be padded with leading zeros
        expect(result[0, 31]).to eq("\x00" * 31)
        expect(result[31, 1]).to eq("\x05")
        # s should be padded with leading zeros
        expect(result[32, 31]).to eq("\x00" * 31)
        expect(result[63, 1]).to eq("\x0a")
      end
    end
  end
end
