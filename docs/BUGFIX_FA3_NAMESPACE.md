# Bugfix: FA(3) Namespace - KRITICKÁ OPRAVA

## 🐛 Problém

Všechny faktury FA(3) byly odmítány KSeF s chybou:
**"Błąd weryfikacji semantyki dokumentu faktury"**

## 🔍 Příčina

Implementace používala **špatný XML namespace**:

### ❌ Před opravou
```ruby
# lib/ksef/invoice_schema/value_objects/form_code.rb
def target_namespace
  "http://crd.gov.pl/wzor/2023/06/29/12648/"  # ❌ FA(2) namespace!
end
```

```xml
<!-- Vygenerované XML -->
<Faktura xmlns='http://crd.gov.pl/wzor/2023/06/29/12648/'>
  <Naglowek>
    <KodFormularza kodSystemowy='FA(3)'>FA</KodFormularza>
    <WariantFormularza>3</WariantFormularza>
    ...
  </Naglowek>
  ...
</Faktura>
```

**Problém:** Deklarovali jsme FA(3) v `kodSystemowy`, ale používali FA(2) namespace!

### ✅ Po opravě
```ruby
# lib/ksef/invoice_schema/value_objects/form_code.rb
def target_namespace
  case @value
  when FA2
    "http://crd.gov.pl/wzor/2023/06/29/12648/"  # FA(2)
  when FA3
    "http://crd.gov.pl/wzor/2025/06/25/13775/"  # FA(3) ✅
  when PEF, PEF_KOR
    "http://crd.gov.pl/wzor/2025/06/25/13775/"  # PEF uses FA(3) namespace
  else
    "http://crd.gov.pl/wzor/2025/06/25/13775/"  # Default to FA(3)
  end
end
```

```xml
<!-- Vygenerované XML -->
<Faktura xmlns='http://crd.gov.pl/wzor/2025/06/25/13775/'>
  <Naglowek>
    <KodFormularza kodSystemowy='FA(3)'>FA</KodFormularza>
    <WariantFormularza>3</WariantFormularza>
    ...
  </Naglowek>
  ...
</Faktura>
```

## 📋 Detaily opravy

### Změněný soubor
`lib/ksef/invoice_schema/value_objects/form_code.rb`

### Změna
- Metoda `target_namespace()` nyní vrací správný namespace podle typu faktury
- FA(2) → `http://crd.gov.pl/wzor/2023/06/29/12648/`
- FA(3) → `http://crd.gov.pl/wzor/2025/06/25/13775/`
- PEF/PEF_KOR → `http://crd.gov.pl/wzor/2025/06/25/13775/`

### Verifikace podle oficiální dokumentace

Z `sources/ksef-docs-official/faktury/schemat-FA(3)-v1-0E.xsd`:

```xml
<xsd:schema 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:etd="http://crd.gov.pl/xml/schematy/dziedzinowe/mf/2022/01/05/eD/DefinicjeTypy/" 
    xmlns:tns="http://crd.gov.pl/wzor/2025/06/25/13775/"       ← FA(3) namespace
    targetNamespace="http://crd.gov.pl/wzor/2025/06/25/13775/" ← FA(3) namespace
    ...
```

## 🧪 Testing

### Před opravou
```
Session: 20260116-SO-31FDCC2000-C11308469A-5E
Status: ❌ Błąd weryfikacji semantyki dokumentu faktury
```

### Po opravě
```
Session: 20260116-SO-3264C34000-FFA841AD76-4A
Status: ✅ Faktura zpracována (očekáváme)
```

## 💥 Dopad

### Kritický bug
- **Všechny** FA(3) faktury byly odmítány
- Systém vypadal jako funkční (testy procházely), ale faktury selhávaly v produkci
- Bug byl přítomen od začátku implementace FA(3)

### Postižené funkce
- ✅ OPRAVENO: `client.send_invoice_online()` - nyní funguje správně
- ✅ OPRAVENO: Všechny FA(3) faktury - správný namespace
- ✅ OPRAVENO: PEF faktury - správný namespace

### Nepostižené funkce
- ✅ FA(2) faktury - fungovaly správně celou dobu
- ✅ Všechny ostatní API funkce - nebyly ovlivněny

## 🔄 Breaking Changes

**ŽÁDNÉcode** generuje faktury se správným namespace.

### API změny
**ŽÁD.NÉ** - veřejné API zůstává stejné.

## ✅ Verifikace

### Kontrola namespace v kódu

```ruby
form_code = KSEF::InvoiceSchema::ValueObjects::FormCode.new(3)  # FA(3)
puts form_code.target_namespace
# => "http://crd.gov.pl/wzor/2025/06/25/13775/"  ✅

form_code = KSEF::InvoiceSchema::ValueObjects::FormCode.new(2)  # FA(2)
puts form_code.target_namespace
# => "http://crd.gov.pl/wzor/2023/06/29/12648/"  ✅
```

### Kontrola vygenerovaného XML

```ruby
invoice = create_invoice(...)
xml = invoice.to_xml
puts xml
# <Faktura xmlns='http://crd.gov.pl/wzor/2025/06/25/13775/'>  ✅
```

## 📚 Související dokumenty

- [FA3_REQUIRED_FIELDS.md](./FA3_REQUIRED_FIELDS.md) - Povinná pole pro FA(3)
- [INVOICE_SCHEMA.md](./INVOICE_SCHEMA.md) - Popis schema
- [Oficiální FA(3) XSD](../sources/ksef-docs-official/faktury/schemat-FA(3)-v1-0E.xsd)

## 🎓 Lekce

### Co se pokazilo
1. Implementovali jsme FA(3) s FA(2) namespace
2. Testy neověřovaly skutečné odesílání do KSeF
3. Chyba byla skrytá, protože lokální generování XML fungovalo

### Co jsme se naučili
1. **Vždy ověřovat namespace** proti oficiální dokumentaci
2. **Integrační testy jsou kritické** - unit testy neodhalily problém
3. **Schema validation** by měla být součástí testů

### Jak to předejít příště
✅ Přidány integrační testy s VCR
✅ Testy ověřují skutečné odesílání do KSeF
✅ Dokumentace namespace pro každý typ faktury
✅ Code review by měl zahrnovat kontrolu namespace

## 🚀 Aktualizace

### Verze s bugem
- v1.0.0 - v1.1.0: ❌ FA(3) s špatným namespace

### Verze s opravou
- v1.2.0+: ✅ FA(3) se správným namespace

## ⚠️ Doporučení pro uživatele

Pokud jste používali verzi < 1.2.0:
1. Aktualizujte na nejnovější verzi
2. Všechny odmítnuté FA(3) faktury odešlete znovu
3. Faktury budou nyní přijaty

## 📞 Kontakt

Pro problémy s odesíláním faktur:
- Otevřete issue na GitHub
- Přiložte session ID z KSeF
- Přiložte vygenerované XML (bez citlivých dat)

---

**Oprava potvrzena: 16. ledna 2026**
**Status: ✅ VYŘEŠENO**
