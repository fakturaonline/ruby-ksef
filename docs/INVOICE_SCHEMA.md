# KSeF Invoice Schema (FA/2 XML)

Pragmatic approach to creating FA(2) XML invoices for KSeF API.

## Overview

Ruby implementation of XML invoice schema for KSeF (Krajowy System e-Faktur). Includes essential components for creating valid FA(2) invoices.

## Quick Start

```ruby
require 'ksef'

# 1. Create seller
seller = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: '1234567890',
    nazwa: 'My Company Ltd.'
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: 'PL',
    miejscowosc: 'Warszawa',
    kod_pocztowy: '00-001',
    ulica: 'Marszałkowska',
    nr_domu: '1'
  )
)

# 2. Create buyer
buyer = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: '9876543210',
    nazwa: 'Customer Sp. z o.o.'
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: 'PL',
    miejscowosc: 'Kraków',
    kod_pocztowy: '30-001',
    ulica: 'Floriańska',
    nr_domu: '5'
  )
)

# 3. Create invoice lines
lines = [
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 1,
    p_7: 'Consulting services',
    p_8a: 'pcs',
    p_8b: 1,
    p_9b: 1000.00,
    p_11: 23,
    p_12: 230.00
  )
]

# 4. Compose invoice
invoice = KSEF::InvoiceSchema::Faktura.new(
  naglowek: KSEF::InvoiceSchema::Naglowek.new(
    system_info: 'My System v1.0'
  ),
  podmiot1: seller,
  podmiot2: buyer,
  fa: KSEF::InvoiceSchema::Fa.new(
    kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new('PLN'),
    p_1: Date.today,
    p_2: 'FV/2024/001',
    p_15: 1230.00,
    fa_wiersz: lines,
    p_13_1: 1000.00,
    p_13_2: 230.00
  )
)

# 5. Generate XML
xml = invoice.to_xml
puts xml
```

## Implemented Components

### ✅ Fully Implemented for FakturaOnline

- **XMLSerializable** - module for XML serialization
- **BaseDTO** - base class for all DTOs
- **Value Objects**:
  - `KodWaluty` - currency code (ISO 4217)
  - `FormCode` - form type (FA(2), FA(3))
  - `RodzajFaktury` - invoice type (VAT, KOREKTA, ZAL...)

- **DTOs**:
  - `Adres` - address (country, city, street, zip code...)
  - `DaneIdentyfikacyjne` - identification data (NIP, name)
  - `DaneKontaktowe` - contact data (email, phone) ✨ **NEW**
  - `Podmiot1` - seller (including contacts)
  - `Podmiot2` - buyer (including contacts)
  - `FaWiersz` - invoice line
  - `Adnotacje` - annotations
  - `RachunekBankowy` - bank account (IBAN, SWIFT) ✨ **NEW**
  - `TerminPlatnosci` - payment deadline ✨ **NEW**
  - `Platnosc` - payment conditions ✨ **NEW**
  - `Stopka` - footer with annotations ✨ **NEW**

- **Main Components**:
  - `Naglowek` - invoice header
  - `Fa` - invoice body (with P_1M, P_6/DUZP, Platnosc) ✨ **EXTENDED**
  - `Faktura` - root element (with Stopka) ✨ **EXTENDED**

### 📋 Mapping FakturaOnline → KSeF

| FakturaOnline field | KSeF XML field | DTO |
|---------------------|----------------|-----|
| `number` | `P_2` | Fa |
| `issued_on` | `P_1` | Fa |
| `due_on` | `TerminPlatnosci.Termin` | Platnosc |
| `tax_point_on` | `P_6` | Fa |
| `currency` | `KodWaluty` | Fa |
| `total` | `P_15` | Fa |
| `seller.name` | `Podmiot1.Nazwa` | Podmiot1 |
| `seller.email` | `DaneKontaktowe.Email` | Podmiot1 |
| `seller.phone` | `DaneKontaktowe.Telefon` | Podmiot1 |
| `seller.bank_account` | `RachunekBankowy.NrRBIBAN` | Platnosc |
| `buyer.name` | `Podmiot2.Nazwa` | Podmiot2 |
| `note` | `Adnotacje.P_16` | Fa |
| `foot_note` | `Stopka.Informacje` | Stopka |
| `lines[].description` | `FaWiersz.P_7` | FaWiersz |
| `lines[].quantity` | `FaWiersz.P_8B` | FaWiersz |
| `lines[].vat_rate` | `FaWiersz.P_11` | FaWiersz |

### 🔄 You Can Add Later

If you need more advanced features:

- `Podmiot3` - third party
- `PodmiotUpowazniony` - authorized entity
- `P_*Group` - VAT field groups for different rates
- `Rozliczenie` - settlement
- `WarunkiTransakcji` - transaction conditions
- `Zalacznik` - attachments
- `KorektaGroup` - corrective invoices
- Advanced validation

## XML Structure

Generated XML conforms to FA(2) schema:

```xml
<?xml version='1.0' encoding='UTF-8'?>
<Faktura xmlns='http://crd.gov.pl/wzor/2023/06/29/12648/'
         xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
         xmlns:etd='http://crd.gov.pl/xml/schematy/dziedzinowe/mf/2022/01/05/eD/DefinicjeTypy/'>
  <Naglowek>...</Naglowek>
  <Podmiot1>...</Podmiot1>
  <Podmiot2>...</Podmiot2>
  <Fa>
    <KodWaluty>PLN</KodWaluty>
    <P_1>2024-01-15</P_1>
    <P_2>FV/2024/001</P_2>
    <P_13_1>1000.00</P_13_1>
    <P_13_2>230.00</P_13_2>
    <P_15>1230.00</P_15>
    <Adnotacje/>
    <RodzajFaktury>VAT</RodzajFaktury>
    <FaWiersz>...</FaWiersz>
  </Fa>
</Faktura>
```

## API Reference

### Faktura

Invoice root element.

```ruby
KSEF::InvoiceSchema::Faktura.new(
  naglowek: Naglowek,
  podmiot1: Podmiot1,
  podmiot2: Podmiot2,
  fa: Fa
)
```

**Methods:**
- `#to_xml` - returns formatted XML string
- `#to_rexml` - returns REXML::Document

### Naglowek

Invoice header with metadata.

```ruby
KSEF::InvoiceSchema::Naglowek.new(
  wariant_formularza: ValueObjects::FormCode.new, # FA(2) or FA(3)
  data_wytworzenia_fa: Time.now,
  system_info: 'My System v1.0'  # optional
)
```

### Podmiot1 / Podmiot2

Seller / Buyer.

```ruby
KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: DaneIdentyfikacyjne,
  adres: Adres,
  adres_koresp: Adres,           # optional
  id_vat: 'PL1234567890',        # optional
  numer_we_wp_ue: 'XX123456789'  # optional
)
```

### Fa

Invoice body.

```ruby
KSEF::InvoiceSchema::Fa.new(
  kod_waluty: ValueObjects::KodWaluty.new('PLN'),
  p_1: Date.today,              # issue date
  p_2: 'FV/2024/001',           # invoice number
  p_15: 1230.00,                # total amount
  fa_wiersz: [FaWiersz],        # invoice lines
  p_13_1: 1000.00,              # tax base 23%
  p_13_2: 230.00,               # VAT 23%
  adnotacje: Adnotacje.new,
  rodzaj_faktury: ValueObjects::RodzajFaktury.new('VAT')
)
```

### FaWiersz

Invoice line item.

```ruby
KSEF::InvoiceSchema::DTOs::FaWiersz.new(
  nr_wiersza: 1,
  p_7: 'Service name',
  p_8a: 'pcs',                  # unit (optional)
  p_8b: 1,                      # quantity (optional)
  p_9a: 1000.00,                # unit price net (optional)
  p_9b: 1000.00,                # net value
  p_11: 23,                     # VAT rate (% or 'zw', 'np', 'oo')
  p_12: 230.00                  # VAT amount
)
```

## Examples

**Basic example:**
```bash
cd ..  # from docs/ back to project root
ruby examples/invoice_example.rb
```

**Complete FakturaOnline mapping:**
```bash
cd ..  # from docs/ back to project root
ruby examples/fakturaonline_mapping.rb
```

This example demonstrates complete mapping of all important fields from FakturaOnline to KSeF FA(2) XML, including:
- Contact information (email, phone)
- Bank accounts (IBAN, SWIFT)
- Payment deadline
- DUZP (tax point date)
- Footer with annotations

## Extension

If you need to add more components:

1. Create a new DTO/ValueObject in the appropriate folder
2. Implement the `XMLSerializable` module
3. Add the `to_rexml` method
4. Require the file in `lib/ksef/invoice_schema.rb`

```ruby
class MyNewDTO < BaseDTO
  include XMLSerializable

  def initialize(field1:, field2: nil)
    @field1 = field1
    @field2 = field2
  end

  def to_rexml
    doc = REXML::Document.new
    element = doc.add_element('MyNewDTO')

    add_element_if_present(element, 'Field1', @field1)
    add_element_if_present(element, 'Field2', @field2)

    doc
  end
end
```

## Testing

```bash
# Run example
ruby examples/invoice_example.rb

# Run tests (once you create them)
bundle exec rspec spec/invoice_schema
```

## Reference

- [KSeF Official Documentation](https://www.gov.pl/web/kas/krajowy-system-e-faktur)
- [FA(2) XML Schema](sources/ksef-docs-official/faktury/)
- [PHP Implementation](ksef-php-client/src/DTOs/Requests/Sessions/)
