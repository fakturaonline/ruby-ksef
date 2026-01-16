# Integration Testing - Shrnutí implementace

## ✅ Co bylo přidáno

### 1. VCR Gem pro nahrávání HTTP interakcí

**Přidáno do `Gemfile`:**
```ruby
gem "vcr", "~> 6.0"
```

### 2. VCR Konfigurace

**`spec/spec_helper.rb`** - přidána kompletní VCR konfigurace:
- Nahrávání HTTP interakcí do cassettes
- Automatické filtrování citlivých dat (tokeny, NIP)
- Integrace s RSpec metadata
- Match strategy pro requesty

### 3. Integrační test pro odesílání faktur

**`spec/integration/invoice_sending_spec.rb`** - kompletní test workflow:
- Vytvoření FA(3) faktury
- Autentizace pomocí KSeF tokenu
- Odesílání faktury přes high-level API `send_invoice_online`
- Verifikace response
- VCR cassette pro offline běh

### 4. Dokumentace

**`docs/TESTING.md`** - komplexní guide:
- Jak spustit testy
- Jak získat test token
- Jak VCR funguje
- Troubleshooting
- Best practices

**`spec/integration/README.md`** - quick start pro integraci:
- Základní použití
- Získání tokenu
- Aktualizace cassettes

### 5. Helper Scripts

**`bin/get_test_token.rb`** - utility pro získání tokenu:
- Autentizace pomocí certifikátu
- Vytvoření KSeF tokenu
- Výpis tokenu pro použití v testech

### 6. Vylepšení ClientBuilder

**`lib/ksef/client_builder.rb`:**
- Přidán alias `nip` pro metodu `identifier`
- Lepší ergonomie pro uživatele

## 🎯 Výsledek

### Před implementací
- ❌ Žádné integrační testy
- ❌ Nemožnost ověřit, že odesílání skutečně funguje
- ❌ Nutnost manuálního testování

### Po implementaci
- ✅ **Kompletní integrační test** pro odesílání faktur
- ✅ **VCR cassettes** - testy běží offline a jsou 60x rychlejší
- ✅ **Automatické filtrování** citlivých dat
- ✅ **Dokumentace** pro další vývojáře
- ✅ **Ověřeno na reálném API** - faktura byla úspěšně odeslána!

## 📊 Metriky

### První běh (s reálným API)
```
✓ Invoice sent successfully!
  Invoice Reference: 20260116-EE-319390D000-C1162E4695-FD
  Session Reference: 20260116-SO-3193718000-8E6D363AC7-52

Finished in 3.7 seconds
```

### Druhý běh (s VCR cassettes)
```
✓ Invoice sent successfully!
  Invoice Reference: 20260116-EE-319390D000-C1162E4695-FD
  Session Reference: 20260116-SO-3193718000-8E6D363AC7-52

Finished in 0.06 seconds  ⚡ (60x faster!)
```

## 🔒 Bezpečnost

### Filtrované údaje v cassettes
- ✅ KSeF tokeny → `<KSEF_TOKEN>`
- ✅ NIP čísla → `<NIP>`
- ✅ Session tokeny → `<KSEF_TOKEN>`

### Cassettes lze bezpečně commitnout
```
spec/fixtures/vcr_cassettes/
  └── invoice_sending/
      └── successful_fa3_highlevel.yml  ← Citlivá data filtrována!
```

## 🧪 Test Coverage

Test ověřuje **celý flow**:

1. ✅ **Autentizace** - KSeF token authentication
2. ✅ **Získání certifikátů** - z KSeF security endpoint
3. ✅ **Generování šifrovacích klíčů** - AES-256
4. ✅ **Šifrování klíče** - RSA-OAEP SHA-256
5. ✅ **Otevření session** - online session s encryption info
6. ✅ **Šifrování faktury** - AES-256-CBC
7. ✅ **Hash calculation** - SHA-256 pro originál + encrypted
8. ✅ **Odesílání** - POST do KSeF API
9. ✅ **Response parsing** - získání reference numbers

## 🚀 Použití

### Pro vývojáře

```ruby
# Spusťte test
bundle exec rspec spec/integration/invoice_sending_spec.rb

# První běh: nahraje HTTP interakce do VCR cassettes
# Další běhy: přehrává cassettes (offline, rychlé)
```

### Pro CI/CD

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: bundle exec rspec
  # Testy běží offline s VCR cassettes
  # Není potřeba platný token!
```

### Pro uživatele gemu

```ruby
# Odesílání faktury je nyní ověřené a testované!
client = KSEF.build do
  mode :test
  identifier "7980332920"
  ksef_token "your-token"
end

# High-level API s automatickým šifrováním
response = client.send_invoice_online(invoice_xml)
```

## 📝 Testovací data

Pro testy používáme:
- **NIP prodejce**: `7980332920` (testovací prostředí)
- **NIP kupujícího**: `1234567890` (testovací)
- **Částka**: 123,00 PLN (100,00 + 23% DPH)
- **Forma faktury**: FA(3) - aktuální pro KSeF API 2.0

## 🎓 Naučené lekce

### VCR Matching Strategy

❌ **Nefunguje:**
```ruby
match_requests_on: [:method, :uri, :body]
```
Protože `encryptedToken` v body obsahuje timestamp a mění se.

✅ **Funguje:**
```ruby
match_requests_on: [:method, :uri]
```
Matchuje pouze HTTP metodu a URI, ignoruje body.

### Client Creation v RSpec

❌ **Nefunguje:**
```ruby
let(:client) { KSEF.build { ... } }  # Volá se mimo VCR context
```

✅ **Funguje:**
```ruby
it "test", vcr: {...} do
  client = KSEF.build { ... }  # Volá se uvnitř VCR context
end
```

## 🔧 Maintenance

### Kdy aktualizovat cassettes?

1. **Změnilo se KSeF API** - nové verze, endpointy
2. **Změnila se interní logika** - jiné requesty
3. **Cassettes jsou staré** - > 6 měsíců

### Jak aktualizovat?

```bash
# 1. Smažte staré cassettes
rm -rf spec/fixtures/vcr_cassettes/invoice_sending/

# 2. Získejte nový platný token
# (viz docs/TESTING.md)

# 3. Spusťte test
bundle exec rspec spec/integration/invoice_sending_spec.rb

# 4. Commitněte nové cassettes
git add spec/fixtures/vcr_cassettes/
git commit -m "Update VCR cassettes"
```

## 📚 Další kroky

Možná rozšíření:

- [ ] Test pro batch sending
- [ ] Test pro stažení UPO
- [ ] Test pro query invoices
- [ ] Test pro chybové stavy
- [ ] Test pro certificate enrollment
- [ ] Performance testy

## 🎉 Závěr

Projekt nyní má:
- ✅ **Funkční integrační testy**
- ✅ **Ověřené odesílání faktur** do KSeF
- ✅ **VCR pro offline běh** testů
- ✅ **Kompletní dokumentaci**
- ✅ **Helper utility** pro získání tokenů

**Vše je připraveno k použití a dalšímu vývoji!** 🚀
