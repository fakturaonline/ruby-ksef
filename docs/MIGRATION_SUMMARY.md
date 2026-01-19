# Souhrn migrace API URL - 19. ledna 2026

## ⚠️ Status: Částečně hotovo

Gem byl úspěšně aktualizován na nové KSeF API URL adresy.
**Akce potřebná:** Nahrání nových VCR cassettes s platným tokenem.

## 📋 Co bylo provedeno

### 1. Aktualizace dokumentace (9 souborů)
- ✅ `README.md` - Hlavní dokumentace
- ✅ `docs/QUICK_START.md` - Quick start průvodce
- ✅ `docs/TESTING.md` - Testovací dokumentace
- ✅ `docs/ARCHITECTURE.md` - Architektura
- ✅ `docs/README.md` - Kompletní dokumentace
- ✅ `docs/CHANGELOG.md` - Historie změn
- ✅ `docs/API_URL_MIGRATION.md` - Migrační průvodce (NOVÝ)
- ✅ `sources/ksef-docs-official/srodowiska.md` - Oficiální dokumentace s poznámkou
- ✅ `spec/integration/README.md` - Integrační testy

### 2. Aktualizace helper skriptů (1 soubor)
- ✅ `bin/get_test_token.rb` - Upřesněn komentář o webovém rozhraní

### 3. Aktualizace testů (1 soubor)
- ✅ `spec/value_objects/mode_spec.rb` - Testy pro URL + přidán test pro demo

### 4. Kód aplikace
- ✅ `lib/ksef/value_objects/mode.rb` - Již obsahoval správné URL (žádná změna nutná)

## 🔄 Nové vs. Staré URL

| Prostředí | Nové (aktivní) | Staré (deprecated) |
|-----------|----------------|---------------------|
| Test | `https://api-test.ksef.mf.gov.pl/v2` | ~~`https://ksef-test.mf.gov.pl/api/v2`~~ |
| Demo | `https://api-demo.ksef.mf.gov.pl/v2` | ~~`https://ksef-demo.mf.gov.pl/api/v2`~~ |
| Production | `https://api.ksef.mf.gov.pl/v2` | ~~`https://ksef.mf.gov.pl/api/v2`~~ |

## 🎯 Dopad na uživatele

### ✅ Žádné změny potřeba
Uživatelé gemu **nepotřebují měnit žádný kód**. Gem automaticky používá správné URL.

```ruby
# Tento kód funguje beze změn
client = KSEF.build do
  mode :test  # Automaticky používá nové URL
  certificate_path 'cert.p12', 'password'
  identifier '1234567890'
end
```

### ⚠️ Pouze pro custom URL
Pokud někdo explicitně nastavoval `api_url`, měl by aktualizovat na nové adresy.

## 🧪 Testování

Všechny testy prošly úspěšně:

```bash
$ bundle exec rspec spec/value_objects/mode_spec.rb

Finished in 0.28461 seconds
21 examples, 0 failures ✅
```

## 📚 Dokumenty

- 📘 [Kompletní migrační průvodce](API_URL_MIGRATION.md)
- 📗 [Changelog](CHANGELOG.md#unreleased---2026-01-19)
- 🎬 [VCR Recording Guide](VCR_RECORDING_GUIDE.md) - **NOVÝ**

## ⏰ Timeline

- **19.1.2026 14:00** - Gem aktualizován na nové URL
- **19.1.2026 16:56** - VCR cassettes smazány
- **Test kódu:** ✅ Prošel (mode_spec.rb)
- **VCR cassettes:** ⏳ Potřeba nahrát znovu

## 🎯 Další kroky (pro vývojáře)

### 1. Získat KSeF token
```bash
# Pomocí scriptu:
ruby bin/get_test_token.rb cert.p12 password 1234567890

# Nebo přes web:
# https://ksef-test.mf.gov.pl/ → Ustawienia → Tokeny
```

### 2. Nastavit v testu
```ruby
# spec/integration/invoice_sending_spec.rb
let(:test_ksef_token) { "VÁŠ_TOKEN" }
let(:test_nip) { "1234567890" }
```

### 3. Nahrát cassettes
```bash
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

### 4. Ověřit
```bash
# Zkontroluj nové URL v cassettes
grep "api-test.ksef.mf.gov.pl" spec/fixtures/vcr_cassettes/invoice_sending/*.yml
```

### Detailní návod
👉 **[VCR Recording Guide](VCR_RECORDING_GUIDE.md)** - Kompletní návod krok za krokem

---

**Status:** ⚠️ **Částečně hotovo** - potřeba nahrát VCR cassettes
**Breaking changes:** ❌ **Žádné** (pro běžné použití)
**Akce pro uživatele:** ✅ **Žádná nutná** (pokud nepoužívají VCR cassettes)
