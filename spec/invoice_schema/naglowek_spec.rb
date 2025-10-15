# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KSEF::InvoiceSchema::Naglowek do
  describe '#to_rexml' do
    it 'generates XML with system info' do
      naglowek = described_class.new(
        system_info: 'Test System v1.0'
      )

      xml = naglowek.to_rexml.to_s

      expect(xml).to include('<Naglowek>')
      expect(xml).to include('<KodFormularza')
      expect(xml).to include('kodSystemowy=')
      expect(xml).to include('wersjaSchemy=')
      expect(xml).to include('>FA</KodFormularza>')
      expect(xml).to include('<WariantFormularza>')
      expect(xml).to include('<DataWytworzeniaFa>')
      expect(xml).to include('<SystemInfo>Test System v1.0</SystemInfo>')
    end

    it 'generates XML without system info' do
      naglowek = described_class.new

      xml = naglowek.to_rexml.to_s

      expect(xml).to include('<Naglowek>')
      expect(xml).not_to include('<SystemInfo>')
    end

    it 'uses custom form code' do
      form_code = KSEF::InvoiceSchema::ValueObjects::FormCode.new('FA(3)')
      naglowek = described_class.new(wariant_formularza: form_code)

      xml = naglowek.to_rexml.to_s

      expect(xml).to include("kodSystemowy='FA(3)'")
    end

    it 'formats date correctly' do
      time = Time.new(2024, 1, 15, 10, 30, 45)
      naglowek = described_class.new(data_wytworzenia_fa: time)

      xml = naglowek.to_rexml.to_s

      expect(xml).to match(/<DataWytworzeniaFa>2024-01-15T\d{2}:\d{2}:\d{2}Z<\/DataWytworzeniaFa>/)
    end
  end
end
