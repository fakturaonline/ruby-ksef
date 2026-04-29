# frozen_string_literal: true

require_relative "../lib/ksef"

# Příklad vytvoření základní FA(3) faktury (KSeF 2.0)

# 1. Vytvoření prodejce (Podmiot1)
prodejce_dane = KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
  nip: "1234567890",
  nazwa: "Firma s.r.o."
)

# FA(3): Adresa má pouze 2 řádky (AdresL1, AdresL2)
prodejce_adres = KSEF::InvoiceSchema::DTOs::Adres.new(
  kod_kraju: "PL",
  adres_l1: "Marszałkowska 1/10", # První řádek: ulice + číslo
  adres_l2: "00-001 Warszawa" # Druhý řádek: PSČ + město
)

prodejce = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: prodejce_dane,
  adres: prodejce_adres
)

# 2. Vytvoření kupujícího (Podmiot2)
kupujici_dane = KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
  nip: "9876543210",
  nazwa: "Klient Sp. z o.o."
)

# FA(3): Adresa má pouze 2 řádky (AdresL1, AdresL2)
kupujici_adres = KSEF::InvoiceSchema::DTOs::Adres.new(
  kod_kraju: "PL",
  adres_l1: "Floriańska 5",              # První řádek: ulice + číslo
  adres_l2: "30-001 Kraków"              # Druhý řádek: PSČ + město
)

# FA(3): Podmiot2 vyžaduje JST a GV (1=ano, 2=ne)
kupujici = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: kupujici_dane,
  adres: kupujici_adres,
  jst: 2,  # Není jednotka podřízená JST
  gv: 2    # Není člen skupiny VAT
)

# 3. Vytvoření položek faktury
polozky = [
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 1,
    p_7: "Konzultační služby",
    p_8a: "ks",
    p_8b: 1,
    p_9a: 1000.00,
    p_9b: 1000.00,
    p_11: 23,
    p_12: 230.00
  ),
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 2,
    p_7: "Vývoj software",
    p_8a: "h",
    p_8b: 10,
    p_9a: 500.00,
    p_9b: 5000.00,
    p_11: 23,
    p_12: 1150.00
  )
]

# 4. Vytvoření hlavní části faktury (Fa)
fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
  p_1: Date.today,
  p_2: "FV/2024/001",
  p_15: 7380.00,
  fa_wiersz: polozky,
  p_13_1: 6000.00,  # FA(3): Základ daně 23%
  p_14_1: 1380.00   # FA(3): DPH 23%
)

# 5. Vytvoření hlavičky (Naglowek)
naglowek = KSEF::InvoiceSchema::Naglowek.new(
  system_info: "Ruby KSEF Client v1.0"
)

# 6. Složení kompletní faktury
faktura = KSEF::InvoiceSchema::Faktura.new(
  naglowek: naglowek,
  podmiot1: prodejce,
  podmiot2: kupujici,
  fa: fa
)

# 7. Vygenerování XML
xml = faktura.to_xml

puts "=" * 80
puts "VYGENEROVANÁ FA(3) FAKTURA (KSeF 2.0)"
puts "=" * 80
puts xml
puts "=" * 80
puts
puts "XML faktura úspěšně vygenerována!"
puts "Velikost: #{xml.bytesize} bytů"
