# frozen_string_literal: true

require_relative "../lib/ksef"

# Příklad mappingu z FakturaOnline do KSeF FA(3) XML (KSeF 2.0)
# Kompletní demo všech důležitých polí

# Simulace dat z FakturaOnline
invoice_data = {
  # Základní identifikace
  number: "FV/2024/001",
  issued_on: Date.new(2024, 1, 15),
  due_on: Date.new(2024, 2, 15),
  tax_point_on: Date.new(2024, 1, 15),

  # Finanční údaje
  currency: "PLN",
  total: 1230.00,

  # Platební údaje
  means_of_payment: "bank_transfer", # => forma_platnosci: '6'
  payment_symbol: "2024001",

  # Poznámky
  note: "Děkujeme za vaši objednávku",
  foot_note: "Faktura vystavena elektronicky.",
  issued_by: "Jan Novák",

  # Seller data
  seller: {
    name: "Moje Firma s.r.o.",
    company_number: "1234567890",
    tax_number: "PL1234567890",
    street: "Marszałkowska 1",
    city: "Warszawa",
    postcode: "00-001",
    country_code: "PL",
    email: "faktura@mojefirma.pl",
    phone: "+48 123 456 789",
    bank_account_number: "PL61109010140000071219812874",
    swift: "WBKPPLPP"
  },

  # Buyer data
  buyer: {
    name: "Zákazník Sp. z o.o.",
    company_number: "9876543210",
    tax_number: "PL9876543210",
    street: "Floriańska 5",
    city: "Kraków",
    postcode: "30-001",
    country_code: "PL",
    email: "zakaznik@firma.pl",
    phone: "+48 987 654 321"
  },

  # Invoice lines
  lines: [
    {
      description: "Konzultační služby",
      unit_type: "ks",
      quantity: 1,
      price: 1000.00,
      vat_rate: 23.0
    }
  ]
}

# === MAPPING DO KSEF FA(3) ===

# 1. Prodejce (Seller -> Podmiot1)
prodejce = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: invoice_data[:seller][:company_number],
    nazwa: invoice_data[:seller][:name]
  ),
  # FA(3): Adresa má pouze 2 řádky (AdresL1, AdresL2)
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: invoice_data[:seller][:country_code],
    adres_l1: invoice_data[:seller][:street],                           # První řádek: ulice + číslo
    adres_l2: "#{invoice_data[:seller][:postcode]} #{invoice_data[:seller][:city]}"  # Druhý řádek: PSČ + město
  ),
  dane_kontaktowe: KSEF::InvoiceSchema::DTOs::DaneKontaktowe.new(
    email: invoice_data[:seller][:email],
    telefon: invoice_data[:seller][:phone]
  )
  # Note: VAT ID je v DaneIdentyfikacyjne jako NIP nebo kod_ue+nr_vat_ue
)

# 2. Kupující (Buyer -> Podmiot2)
kupujici = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: invoice_data[:buyer][:company_number],
    nazwa: invoice_data[:buyer][:name]
  ),
  # FA(3): Adresa má pouze 2 řádky (AdresL1, AdresL2)
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: invoice_data[:buyer][:country_code],
    adres_l1: invoice_data[:buyer][:street],                            # První řádek: ulice + číslo
    adres_l2: "#{invoice_data[:buyer][:postcode]} #{invoice_data[:buyer][:city]}"   # Druhý řádek: PSČ + město
  ),
  dane_kontaktowe: KSEF::InvoiceSchema::DTOs::DaneKontaktowe.new(
    email: invoice_data[:buyer][:email],
    telefon: invoice_data[:buyer][:phone]
  ),
  jst: 2,  # FA(3): Není jednotka podřízená JST (1=ano, 2=ne)
  gv: 2    # FA(3): Není člen skupiny VAT (1=ano, 2=ne)
)
# Note: VAT ID je v DaneIdentyfikacyjne jako NIP nebo kod_ue+nr_vat_ue

# 3. Položky faktury (lines -> FaWiersz)
polozky = invoice_data[:lines].map.with_index do |line, idx|
  netto = line[:quantity] * line[:price]
  vat_amount = netto * (line[:vat_rate] / 100.0)

  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: idx + 1,
    p_7: line[:description],
    p_8a: line[:unit_type],
    p_8b: line[:quantity],
    p_9a: line[:price],
    p_9b: netto,
    p_11: line[:vat_rate].to_i,
    p_12: vat_amount
  )
end

# 4. Výpočet součtů DPH
vat_23_base = polozky.sum(&:p_9b)
vat_23_amount = polozky.sum(&:p_12)

# 5. Platební údaje
platnosc = KSEF::InvoiceSchema::DTOs::Platnosc.new(
  termin_platnosci: KSEF::InvoiceSchema::DTOs::TerminPlatnosci.new(
    termin: invoice_data[:due_on],
    forma_platnosci: "6", # bank_transfer = 6
    suma_platnosci: invoice_data[:total]
  ),
  rachunek_bankowy: KSEF::InvoiceSchema::DTOs::RachunekBankowy.new(
    nr_rb: invoice_data[:seller][:bank_account_number],
    swift: invoice_data[:seller][:swift]
  ),
  forma_platnosci: "6"
)

# 6. Hlavní část faktury (Fa)
fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new(invoice_data[:currency]),
  p_1: invoice_data[:issued_on],        # issued_on
  p_1m: invoice_data[:seller][:city],   # místo vystavení
  p_2: invoice_data[:number], # number
  p_6: invoice_data[:tax_point_on], # tax_point_on (DUZP)
  p_15: invoice_data[:total],            # total
  fa_wiersz: polozky,
  p_13_1: vat_23_base,                   # FA(3): základ daně 23%
  p_14_1: vat_23_amount,                 # FA(3): DPH 23%
  # FA(3): Adnotacje má pevnou strukturu (P_16, P_17, P_18, atd.) - všechny mají defaulty
  adnotacje: KSEF::InvoiceSchema::DTOs::Adnotacje.new,
  platnosc: platnosc
)

# 7. Zápatí (zde umístíme poznámky)
stopka = KSEF::InvoiceSchema::DTOs::Stopka.new(
  informacje: [
    invoice_data[:note],         # Poznámka z faktury
    invoice_data[:foot_note],    # Poznámka v zápatí
    "Vystavil: #{invoice_data[:issued_by]}"
  ]
)

# 8. Hlavička
naglowek = KSEF::InvoiceSchema::Naglowek.new(
  system_info: "FakturaOnline Ruby Integration v1.0"
)

# 9. Kompletní faktura
faktura = KSEF::InvoiceSchema::Faktura.new(
  naglowek: naglowek,
  podmiot1: prodejce,
  podmiot2: kupujici,
  fa: fa,
  stopka: stopka
)

# 10. Vygenerování XML
xml = faktura.to_xml

puts "=" * 80
puts "FAKTURAONLINE → KSEF FA(3) MAPPING (KSeF 2.0)"
puts "=" * 80
puts xml
puts "=" * 80
puts
puts "✅ Všechna pole z FakturaOnline namapována!"
puts "   - Číslo faktury: #{invoice_data[:number]}"
puts "   - Datum vystavení: #{invoice_data[:issued_on]}"
puts "   - Datum splatnosti: #{invoice_data[:due_on]}"
puts "   - DUZP: #{invoice_data[:tax_point_on]}"
puts "   - Celková částka: #{invoice_data[:total]} #{invoice_data[:currency]}"
puts "   - Prodejce: #{invoice_data[:seller][:name]}"
puts "   - Kupující: #{invoice_data[:buyer][:name]}"
puts "   - Bankovní účet: #{invoice_data[:seller][:bank_account_number]}"
puts "   - Kontakt prodejce: #{invoice_data[:seller][:email]}, #{invoice_data[:seller][:phone]}"
puts
puts "XML velikost: #{xml.bytesize} bytů"
