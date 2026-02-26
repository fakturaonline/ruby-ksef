# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::InvoiceSchema::DTOs::DaneFaKorygowanej do
  let(:original_date) { Date.new(2026, 1, 15) }
  let(:original_number) { "FV/2026/001" }

  describe "#initialize" do
    context "when original was outside KSeF (nr_ksef_n)" do
      subject do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number,
          nr_ksef_n: 1
        )
      end

      it "stores required fields" do
        expect(subject.data_wyst_fa_korygowanej).to eq(original_date)
        expect(subject.nr_fa_korygowanej).to eq(original_number)
        expect(subject.nr_ksef_n).to eq(1)
        expect(subject.nr_ksef_fa_korygowanej).to be_nil
      end
    end

    context "when original was in KSeF (nr_ksef_fa_korygowanej)" do
      subject do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number,
          nr_ksef_fa_korygowanej: "9999999999-20260115-ABCDEF-01"
        )
      end

      it "stores the KSeF reference number" do
        expect(subject.nr_ksef_fa_korygowanej).to eq("9999999999-20260115-ABCDEF-01")
        expect(subject.nr_ksef_n).to be_nil
      end
    end

    it "parses date from string" do
      dane = described_class.new(
        data_wyst_fa_korygowanej: "2026-01-15",
        nr_fa_korygowanej: original_number,
        nr_ksef_n: 1
      )
      expect(dane.data_wyst_fa_korygowanej).to eq(original_date)
    end

    it "raises when data_wyst_fa_korygowanej is missing" do
      expect do
        described_class.new(nr_fa_korygowanej: original_number, nr_ksef_n: 1)
      end.to raise_error(ArgumentError, /data_wyst_fa_korygowanej/)
    end

    it "raises when nr_fa_korygowanej is missing" do
      expect do
        described_class.new(data_wyst_fa_korygowanej: original_date, nr_ksef_n: 1)
      end.to raise_error(ArgumentError, /nr_fa_korygowanej/)
    end

    it "raises when neither nr_ksef_fa_korygowanej nor nr_ksef_n is set" do
      expect do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number
        )
      end.to raise_error(ArgumentError, /nr_ksef_fa_korygowanej or nr_ksef_n/)
    end

    it "raises when both nr_ksef_fa_korygowanej and nr_ksef_n are set" do
      expect do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number,
          nr_ksef_fa_korygowanej: "some-ref",
          nr_ksef_n: 1
        )
      end.to raise_error(ArgumentError, /not both/)
    end
  end

  describe "#to_rexml" do
    context "with nr_ksef_n (outside KSeF)" do
      subject do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number,
          nr_ksef_n: 1
        ).to_rexml.to_s
      end

      it "generates DaneFaKorygowanej element" do
        expect(subject).to include("<DaneFaKorygowanej>")
        expect(subject).to include("<DataWystFaKorygowanej>2026-01-15</DataWystFaKorygowanej>")
        expect(subject).to include("<NrFaKorygowanej>FV/2026/001</NrFaKorygowanej>")
        expect(subject).to include("<NrKSeFN>1</NrKSeFN>")
        expect(subject).not_to include("NrKSeFFaKorygowanej")
      end
    end

    context "with nr_ksef_fa_korygowanej (in KSeF)" do
      subject do
        described_class.new(
          data_wyst_fa_korygowanej: original_date,
          nr_fa_korygowanej: original_number,
          nr_ksef_fa_korygowanej: "9999999999-20260115-ABCDEF-01"
        ).to_rexml.to_s
      end

      it "generates KSeF reference instead of NrKSeFN" do
        expect(subject).to include("<NrKSeFFaKorygowanej>9999999999-20260115-ABCDEF-01</NrKSeFFaKorygowanej>")
        expect(subject).not_to include("NrKSeFN")
      end
    end
  end
end
