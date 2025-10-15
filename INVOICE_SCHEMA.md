# KSeF Invoice Schema (FA/2 XML)

Pragmatický přístup k vytváření FA(2) XML faktur pro KSeF API.

## Přehled

Ruby implementace XML invoice schema pro KSeF (Krajowy System e-Faktur). Zahrnuje základní komponenty pro vytvoření validní FA(2) faktury.

## Rychlý start

```ruby
require 'ksef'

# 1. Vytvoř prodejce
prodejce = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: '1234567890',
    nazwa: 'Moje firma s.r.o.'
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: 'PL',
    miejscowosc: 'Warszawa',
    kod_pocztowy: '00-001',
    ulica: 'Marszałkowska',
    nr_domu: '1'
  )
)

# 2. Vytvoř kupujícího
kupujici = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: '9876543210',
    nazwa: 'Zákazník Sp. z o.o.'
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: 'PL',
    miejscowosc: 'Kraków',
    kod_pocztowy: '30-001',
    ulica: 'Floriańska',
    nr_domu: '5'
  )
)

# 3. Vytvoř položky faktury
polozky = [
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 1,
    p_7: 'Konzultační služby',
    p_8a: 'ks',
    p_8b: 1,
    p_9b: 1000.00,
    p_11: 23,
    p_12: 230.00
  )
]

# 4. Slož fakturu
faktura = KSEF::InvoiceSchema::Faktura.new(
  naglowek: KSEF::InvoiceSchema::Naglowek.new(
    system_info: 'Můj systém v1.0'
  ),
  podmiot1: prodejce,
  podmiot2: kupujici,
  fa: KSEF::InvoiceSchema::Fa.new(
    kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new('PLN'),
    p_1: Date.today,
    p_2: 'FV/2024/001',
    p_15: 1230.00,
    fa_wiersz: polozky,
    p_13_1: 1000.00,
    p_13_2: 230.00
  )
)

# 5. Vygeneruj XML
xml = faktura.to_xml
puts xml
```

## Implementované komponenty

### ✅ Hotovo

- **XMLSerializable** - modul pro XML serializaci
- **BaseDTO** - základní třída pro všechny DTOs
- **Value Objects**:
  - `KodWaluty` - kód měny (ISO 4217)
  - `FormCode` - typ formuláře (FA(2), FA(3))
  - `RodzajFaktury` - typ faktury (VAT, KOREKTA, ZAL...)

- **DTOs**:
  - `Adres` - adresa (kraj, město, ulice, PSČ...)
  - `DaneIdentyfikacyjne` - identifikační údaje (NIP, název)
  - `Podmiot1` - prodejce
  - `Podmiot2` - kupující
  - `FaWiersz` - položka faktury
  - `Adnotacje` - poznámky

- **Hlavní komponenty**:
  - `Naglowek` - hlavička faktury
  - `Fa` - tělo faktury
  - `Faktura` - root element

### 🔄 Můžeš doplnit později

Pokud budeš potřebovat pokročilejší funkce:

- `Podmiot3` - třetí subjekt
- `PodmiotUpowazniony` - oprávněný subjekt
- `P_*Group` - skupiny DPH polí pro různé sazby
- `Platnosc` - podmínky platby
- `Rozliczenie` - rozúčtování
- `WarunkiTransakcji` - obchodní podmínky
- `Stopka` - zápatí
- `Zalacznik` - přílohy
- `KorektaGroup` - opravné faktury
- Pokročilejší validace

## Struktura XML

Vygenerované XML odpovídá FA(2) schema:

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

Root element faktury.

```ruby
KSEF::InvoiceSchema::Faktura.new(
  naglowek: Naglowek,
  podmiot1: Podmiot1,
  podmiot2: Podmiot2,
  fa: Fa
)
```

**Metody:**
- `#to_xml` - vrátí formátovaný XML string
- `#to_rexml` - vrátí REXML::Document

### Naglowek

Hlavička faktury s metadaty.

```ruby
KSEF::InvoiceSchema::Naglowek.new(
  wariant_formularza: ValueObjects::FormCode.new, # FA(2) nebo FA(3)
  data_wytworzenia_fa: Time.now,
  system_info: 'Můj systém v1.0'  # optional
)
```

### Podmiot1 / Podmiot2

Prodejce / Kupující.

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

Hlavní část faktury.

```ruby
KSEF::InvoiceSchema::Fa.new(
  kod_waluty: ValueObjects::KodWaluty.new('PLN'),
  p_1: Date.today,              # datum vystavení
  p_2: 'FV/2024/001',           # číslo faktury
  p_15: 1230.00,                # celková částka
  fa_wiersz: [FaWiersz],        # položky
  p_13_1: 1000.00,              # základ daně 23%
  p_13_2: 230.00,               # DPH 23%
  adnotacje: Adnotacje.new,
  rodzaj_faktury: ValueObjects::RodzajFaktury.new('VAT')
)
```

### FaWiersz

Položka faktury.

```ruby
KSEF::InvoiceSchema::DTOs::FaWiersz.new(
  nr_wiersza: 1,
  p_7: 'Název služby',
  p_8a: 'ks',                   # jednotka (optional)
  p_8b: 1,                      # množství (optional)
  p_9a: 1000.00,                # jedn. cena netto (optional)
  p_9b: 1000.00,                # hodnota netto
  p_11: 23,                     # sazba DPH (% nebo 'zw', 'np', 'oo')
  p_12: 230.00                  # výše DPH
)
```

## Příklady

Viz `examples/invoice_example.rb` pro kompletní příklad.

## Rozšíření

Pokud potřebuješ přidat další komponenty:

1. Vytvoř nový DTO/ValueObject v příslušné složce
2. Implementuj `XMLSerializable` modul
3. Přidej `to_rexml` metodu
4. Načti soubor v `lib/ksef/invoice_schema.rb`

```ruby
class MojeNoveDTO < BaseDTO
  include XMLSerializable

  def initialize(pole1:, pole2: nil)
    @pole1 = pole1
    @pole2 = pole2
  end

  def to_rexml
    doc = REXML::Document.new
    element = doc.add_element('MojeNoveDTO')

    add_element_if_present(element, 'Pole1', @pole1)
    add_element_if_present(element, 'Pole2', @pole2)

    doc
  end
end
```

## Testování

```bash
# Spusť příklad
ruby examples/invoice_example.rb

# Spusť testy (až je vytvoříš)
bundle exec rspec spec/invoice_schema
```

## Reference

- [KSeF Official Documentation](https://www.gov.pl/web/kas/krajowy-system-e-faktur)
- [FA(2) XML Schema](sources/ksef-docs-official/faktury/)
- [PHP Implementation](ksef-php-client/src/DTOs/Requests/Sessions/)
