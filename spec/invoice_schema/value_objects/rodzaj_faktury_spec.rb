# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KSEF::InvoiceSchema::ValueObjects::RodzajFaktury do
  describe '#initialize' do
    it 'accepts VAT' do
      rodzaj = described_class.new(described_class::VAT)
      expect(rodzaj.value).to eq('VAT')
    end

    it 'accepts KOREKTA' do
      rodzaj = described_class.new(described_class::KOREKTA)
      expect(rodzaj.value).to eq('KOREKTA')
    end

    it 'defaults to VAT' do
      rodzaj = described_class.new
      expect(rodzaj.value).to eq('VAT')
    end

    it 'raises error for invalid type' do
      expect { described_class.new('INVALID') }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'returns type string' do
      rodzaj = described_class.new('KOREKTA')
      expect(rodzaj.to_s).to eq('KOREKTA')
    end
  end
end
