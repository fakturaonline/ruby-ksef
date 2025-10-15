#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
require_relative "../lib/ksef"

puts "=== KSEF XML Parser Demo ==="
puts

# 1. Create invoice
puts "1. Creating invoice..."
seller = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: "1234567890",
    nazwa: "Example Company Ltd."
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: "PL",
    miejscowosc: "Warszawa",
    kod_pocztowy: "00-001",
    ulica: "Marszałkowska",
    nr_domu: "1"
  )
)

buyer = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: "9876543210",
    nazwa: "Customer Sp. z o.o."
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: "PL",
    miejscowosc: "Kraków",
    kod_pocztowy: "30-001",
    ulica: "Floriańska",
    nr_domu: "5"
  )
)

lines = [
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 1,
    p_7: "Consulting services",
    p_8a: "pcs",
    p_8b: 1,
    p_9b: 1000.00,
    p_11: 23,
    p_12: 230.00
  ),
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 2,
    p_7: "Development services",
    p_8a: "h",
    p_8b: 10,
    p_9b: 5000.00,
    p_11: 23,
    p_12: 1150.00
  )
]

invoice = KSEF::InvoiceSchema::Faktura.new(
  naglowek: KSEF::InvoiceSchema::Naglowek.new(
    system_info: "Parser Demo"
  ),
  podmiot1: seller,
  podmiot2: buyer,
  fa: KSEF::InvoiceSchema::Fa.new(
    kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
    p_1: Date.today,
    p_2: "FV/2025/001",
    p_15: 7380.00,
    fa_wiersz: lines,
    p_13_1: 6000.00,
    p_13_2: 1380.00
  )
)

puts "✓ Invoice created"

# 2. Serialize to XML
puts "\n2. Serializing to XML..."
xml = invoice.to_xml
puts "✓ XML generated (#{xml.length} bytes)"

# 3. Parse back
puts "\n3. Parsing XML back to objects..."
parsed_invoice = KSEF::InvoiceSchema::Faktura.from_xml(xml)
puts "✓ Invoice parsed"

# 4. Verify data
puts "\n4. Verifying parsed data..."
puts "   Invoice number: #{parsed_invoice.fa.p_2}"
puts "   Issue date: #{parsed_invoice.fa.p_1}"
puts "   Currency: #{parsed_invoice.fa.kod_waluty}"
puts "   Total: #{parsed_invoice.fa.p_15}"
puts "   Seller: #{parsed_invoice.podmiot1.dane_identyfikacyjne.nazwa}"
puts "   Buyer: #{parsed_invoice.podmiot2.dane_identyfikacyjne.nazwa}"
puts "   Lines: #{parsed_invoice.fa.fa_wiersz.size}"

parsed_invoice.fa.fa_wiersz.each do |line|
  puts "     #{line.nr_wiersza}. #{line.p_7} - #{line.p_9b} PLN"
end

# 5. Test round-trip
puts "\n5. Testing round-trip conversion..."
xml2 = parsed_invoice.to_xml
parsed_invoice2 = KSEF::InvoiceSchema::Faktura.from_xml(xml2)

if parsed_invoice2.fa.p_2 == invoice.fa.p_2 &&
   parsed_invoice2.fa.p_15 == invoice.fa.p_15 &&
   parsed_invoice2.fa.fa_wiersz.size == invoice.fa.fa_wiersz.size
  puts "✓ Round-trip conversion successful!"
else
  puts "✗ Round-trip conversion failed!"
end

puts "\n=== Demo Complete ==="
# rubocop:enable Naming/VariableNumber
