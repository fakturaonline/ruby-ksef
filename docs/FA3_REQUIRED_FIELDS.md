# FA(3) - Povinná pole pro KSeF

## ⚠️ Důležité zjištění

Při testování odesílání faktur jsme narazili na chybu:
**"Błąd weryfikacji semantyki dokumentu faktury"**

## 🔍 Příčina

Faktura FA(3) v KSeF vyžaduje **P_6** (datum zdanitelného plnění - DUZP).

### ❌ Chybná faktura (bez P_6)

```ruby
fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
  p_1: Date.today,        # Datum vystavení
  p_2: "FV/2024/001",     # Číslo faktury
  p_15: 123.00,           # Částka celkem
  fa_wiersz: polozky,
  p_13_1: 100.00,         # Základ daně 23%
  p_13_2: 23.00           # DPH 23%
  # ❌ CHYBÍ P_6 - DUZP!
)
```

**Výsledek:** Błąd weryfikacji semantyki dokumentu faktury

### ✅ Správná faktura (s P_6)

```ruby
fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
  p_1: Date.today,        # Datum vystavení
  p_2: "FV/2024/001",     # Číslo faktury
  p_6: Date.today,        # ✅ DUZP - datum zdanitelného plnění
  p_15: 123.00,           # Částka celkem
  fa_wiersz: polozky,
  p_13_1: 100.00,         # Základ daně 23%
  p_13_2: 23.00           # DPH 23%
)
```

**Výsledek:** ✅ Faktura přijata a zpracována

## 📋 Povinná pole pro FA(3)

### Minimální faktura

```ruby
# 1. Naglowek (hlavička)
naglowek = KSEF::InvoiceSchema::Naglowek.new(
  system_info: "Název systému"
)

# 2. Podmiot1 (prodejce)
prodejce = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: "1234567890",
    nazwa: "Firma s.r.o."
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: "PL",
    miejscowosc: "Warszawa",
    kod_pocztowy: "00-001",
    ulica: "Testowa",
    nr_domu: "1"
  )
)

# 3. Podmiot2 (kupující)
kupujici = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
  dane_identyfikacyjne: KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
    nip: "9876543210",
    nazwa: "Klient Sp. z o.o."
  ),
  adres: KSEF::InvoiceSchema::DTOs::Adres.new(
    kod_kraju: "PL",
    miejscowosc: "Kraków",
    kod_pocztowy: "30-001",
    ulica: "Testowa",
    nr_domu: "5"
  )
)

# 4. FaWiersz (položky)
polozky = [
  KSEF::InvoiceSchema::DTOs::FaWiersz.new(
    nr_wiersza: 1,
    p_7: "Popis služby",
    p_8a: "ks",
    p_8b: 1,
    p_9a: 100.00,
    p_9b: 100.00,
    p_11: 23,
    p_12: 23.00
  )
]

# 5. Fa (hlavní část faktury)
fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
  p_1: Date.today,        # ✅ POVINNÉ - Datum vystavení
  p_2: "FV/2024/001",     # ✅ POVINNÉ - Číslo faktury
  p_6: Date.today,        # ✅ POVINNÉ - DUZP (datum zdanitelného plnění)
  p_15: 123.00,           # ✅ POVINNÉ - Částka celkem
  fa_wiersz: polozky,     # ✅ POVINNÉ - Položky (min. 1)
  p_13_1: 100.00,         # ✅ POVINNÉ - Základ daně (pokud je DPH)
  p_13_2: 23.00           # ✅ POVINNÉ - DPH (pokud je DPH)
)

# 6. Faktura (kompletní dokument)
faktura = KSEF::InvoiceSchema::Faktura.new(
  naglowek: naglowek,
  podmiot1: prodejce,
  podmiot2: kupujici,
  fa: fa
)
```

## 🔑 Klíčová pole

### P_1 - Datum vystavení
- **Povinné:** Ano
- **Formát:** `Date` nebo `"YYYY-MM-DD"`
- **Příklad:** `Date.today` nebo `"2024-01-15"`

### P_2 - Číslo faktury
- **Povinné:** Ano
- **Formát:** String
- **Příklad:** `"FV/2024/001"`

### P_6 - DUZP (Datum zdanitelného plnění)
- **Povinné:** **ANO pro FA(3)!** ⚠️
- **Formát:** `Date` nebo `"YYYY-MM-DD"`
- **Příklad:** `Date.today` nebo `"2024-01-15"`
- **Poznámka:** Často stejné jako P_1

### P_15 - Částka celkem
- **Povinné:** Ano
- **Formát:** Numeric (Decimal)
- **Příklad:** `123.00`

### P_13_1, P_13_2 - Základ daně a DPH
- **Povinné:** Ano (pokud je DPH)
- **P_13_1:** Základ daně pro sazbu 23%
- **P_13_2:** DPH pro sazbu 23%
- **Formát:** Numeric (Decimal)
- **Příklad:** `p_13_1: 100.00, p_13_2: 23.00`

### FaWiersz - Položky faktury
- **Povinné:** Ano (minimálně 1 položka)
- **Pole položky:**
  - `nr_wiersza` - Číslo řádku (1, 2, 3, ...)
  - `p_7` - Popis
  - `p_8a` - Jednotka (ks, h, m, ...)
  - `p_8b` - Množství
  - `p_9a` - Cena za jednotku
  - `p_9b` - Hodnota celkem
  - `p_11` - Sazba DPH (23, 8, 5, ...)
  - `p_12` - DPH celkem

## 🚨 Časté chyby

### 1. Chybějící P_6 (DUZP)
```
Błąd: "Błąd weryfikacji semantyki dokumentu faktury"
Řešení: Přidat p_6: Date.today
```

### 2. Nesouhlasí součty
```
Błąd: "Niezgodność sum kontrolnych"
Řešení: Zkontrolovat, že:
  - P_15 = P_13_1 + P_13_2
  - P_13_1 = suma P_9B z položek
  - P_13_2 = suma P_12 z položek
```

### 3. Chybějící položky
```
Błąd: "Brak pozycji faktury"
Řešení: Přidat alespoň 1 položku do fa_wiersz
```

## ✅ Ověřená funkční faktura

Tato faktura byla úspěšně odeslána a zpracována v KSeF test prostředí:

```ruby
# Invoice Reference: 20260116-EE-322A253000-2945BD718B-A6
# Session Reference: 20260116-SO-322A082000-FFA04BA067-CB
# Status: Přijato ✅

fa = KSEF::InvoiceSchema::Fa.new(
  kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
  p_1: Date.today,
  p_2: "TEST/#{Time.now.to_i}/001",
  p_6: Date.today,  # ← KLÍČOVÉ!
  p_15: 123.00,
  fa_wiersz: [
    KSEF::InvoiceSchema::DTOs::FaWiersz.new(
      nr_wiersza: 1,
      p_7: "Testovací služba",
      p_8a: "ks",
      p_8b: 1,
      p_9a: 100.00,
      p_9b: 100.00,
      p_11: 23,
      p_12: 23.00
    )
  ],
  p_13_1: 100.00,
  p_13_2: 23.00
)
```

## 📚 Další informace

- [INVOICE_SCHEMA.md](./INVOICE_SCHEMA.md) - Kompletní popis schématu
- [INVOICE_SENDING_FLOW.md](./INVOICE_SENDING_FLOW.md) - Proces odesílání
- [Oficiální dokumentace KSeF](../sources/ksef-docs-official/)

## 🎓 Závěr

**P_6 (DUZP) je povinné pole pro FA(3) faktury v KSeF!**

Bez tohoto pole KSeF vrátí chybu "Błąd weryfikacji semantyki dokumentu faktury".

Vždy přidávejte `p_6: Date.today` (nebo konkrétní datum zdanitelného plnění) do vašich faktur.
