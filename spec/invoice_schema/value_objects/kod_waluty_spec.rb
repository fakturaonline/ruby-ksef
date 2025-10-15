# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KSEF::InvoiceSchema::ValueObjects::KodWaluty do
  describe '#initialize' do
    it 'accepts valid currency code' do
      kod = described_class.new('PLN')
      expect(kod.value).to eq('PLN')
    end

    it 'converts to uppercase' do
      kod = described_class.new('pln')
      expect(kod.value).to eq('PLN')
    end

    it 'raises error for invalid format' do
      expect { described_class.new('PLNX') }.to raise_error(ArgumentError)
      expect { described_class.new('PL') }.to raise_error(ArgumentError)
      expect { described_class.new('12') }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'returns currency code string' do
      kod = described_class.new('EUR')
      expect(kod.to_s).to eq('EUR')
    end
  end
end
