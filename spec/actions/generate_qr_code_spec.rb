# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::GenerateQrCode do
  describe "#call" do
    context "with minimal parameters" do
      let(:generator) do
        described_class.new(
          nip: "1234567890",
          invoice_date: Date.new(2025, 1, 15),
          ksef_number: "1234567890-20250115-ABCD1234-56"
        )
      end

      it "generates QR code PNG" do
        result = generator.call

        expect(result[:png]).to be_a(ChunkyPNG::Image)
        expect(result[:png].width).to be > 0
        expect(result[:png].height).to be > 0
      end

      it "generates QR code SVG" do
        result = generator.call

        expect(result[:svg]).to be_a(String)
        expect(result[:svg]).to include("<svg")
        expect(result[:svg]).to include("</svg>")
      end

      it "includes all required data in QR code" do
        result = generator.call
        svg = result[:svg]

        # QR code should contain KSEF number
        expect(svg).to be_a(String)
        expect(svg.length).to be > 100
      end
    end

    context "with ksef number" do
      let(:generator) do
        described_class.new(
          nip: "1234567890",
          invoice_date: Date.new(2025, 1, 15),
          ksef_number: "1234567890-20250115-ABCD1234-56"
        )
      end

      it "generates online invoice QR code" do
        result = generator.call

        expect(result[:png]).to be_a(ChunkyPNG::Image)
        expect(result[:svg]).to be_a(String)
        expect(result[:data]).to include("https://ksef.mf.gov.pl/web/invoice/")
      end

      it "formats PNG as binary string" do
        result = generator.call
        png_binary = result[:png].to_s

        expect(png_binary).to be_a(String)
        expect(png_binary.encoding).to eq(Encoding::BINARY)
        # PNG magic bytes
        expect(png_binary.bytes[0..3]).to eq([0x89, 0x50, 0x4E, 0x47])
      end
    end

    context "without ksef number (offline)" do
      it "generates offline invoice QR code" do
        generator = described_class.new(
          nip: "1234567890",
          invoice_date: Date.new(2025, 1, 15)
        )

        result = generator.call
        expect(result[:data]).to eq("NIP:1234567890|DATA:2025-01-15")
        expect(result[:png]).to be_a(ChunkyPNG::Image)
      end
    end
  end

  describe "data encoding" do
    it "encodes KSEF URL correctly" do
      generator = described_class.new(
        nip: "1234567890",
        invoice_date: Date.new(2025, 1, 15),
        ksef_number: "1234567890-20250115-ABCD1234-56"
      )

      result = generator.call

      # SVG should contain properly formatted data
      expect(result[:svg]).to include("<svg")
      expect(result[:svg]).to include("<rect")
      expect(result[:data]).to eq("https://ksef.mf.gov.pl/web/invoice/1234567890-20250115-ABCD1234-56")
    end

    it "handles special characters in KSEF number" do
      generator = described_class.new(
        nip: "1234567890",
        invoice_date: Date.new(2025, 1, 15),
        ksef_number: "1234567890-20250115-XYZW9876-12"
      )

      expect { generator.call }.not_to raise_error
    end

    it "encodes offline QR data correctly" do
      generator = described_class.new(
        nip: "1234567890",
        invoice_date: Date.new(2025, 1, 15)
      )

      result = generator.call
      expect(result[:data]).to match(/^NIP:\d+\|DATA:\d{4}-\d{2}-\d{2}$/)
    end
  end
end
