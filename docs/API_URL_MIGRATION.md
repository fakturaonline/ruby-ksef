# API URL Migration - January 2026

## Overview of Changes

In January 2026, KSeF officially moved to new API addresses. Old addresses are marked as **deprecated**.

## New vs. Old URLs

| Environment | New Address (active) | Old Address (deprecated) |
|-----------|----------------------|---------------------------|
| **Test** | `https://api-test.ksef.mf.gov.pl/v2` | `https://ksef-test.mf.gov.pl/api/v2` |
| **Demo** | `https://api-demo.ksef.mf.gov.pl/v2` | `https://ksef-demo.mf.gov.pl/api/v2` |
| **Production** | `https://api.ksef.mf.gov.pl/v2` | `https://ksef.mf.gov.pl/api/v2` |

### Web Interface (unchanged)

Web interface remains at original addresses:
- Test: `https://ksef-test.mf.gov.pl` (bez `/api`)
- Demo: `https://ksef-demo.mf.gov.pl`
- Production: `https://ksef.mf.gov.pl`

## What Was Updated

### 1. Application Code
✅ `lib/ksef/value_objects/mode.rb` - Konstanty s URL (již měly správné hodnoty)

### 2. Dokumentace
✅ `README.md` - Aktualizované příklady prostředí
✅ `docs/QUICK_START.md` - Aktualizované URL v příkladech
✅ `docs/TESTING.md` - Aktualizované odkazy na API
✅ `docs/ARCHITECTURE.md` - Aktualizované příklady mockování
✅ `docs/README.md` - Přidán odkaz na nové API
✅ `docs/CHANGELOG.md` - Přidán záznam o migraci
✅ `sources/ksef-docs-official/srodowiska.md` - Přidána poznámka o nových URL

### 3. Helper skripty
✅ `bin/get_test_token.rb` - Aktualizovaný komentář s poznámkou o webovém rozhraní

### 4. Testy
✅ `spec/value_objects/mode_spec.rb` - Aktualizované očekávané URL v testech
✅ `spec/integration/README.md` - Aktualizované odkazy na API

### 5. Co bylo SMAZÁNO
🔄 **VCR cassettes** - Všechny cassettes smazány (19.1.2026) kvůli migrace na nové URL
   - Potřeba nahrát znovu s platným tokenem
   - Viz [VCR Recording Guide](VCR_RECORDING_GUIDE.md)

### 6. Co NEBYLO měněno
❌ **Webové odkazy** - Odkazy na web interface zůstávají na původních URL

## Dopad na uživatele

### ✅ Žádné změny v kódu
Uživatelé gemu **nepotřebují měnit svůj kód**. Gem automaticky používá správné URL:

```ruby
# Automaticky používá https://api-test.ksef.mf.gov.pl/v2
client = KSEF.build do
  mode :test
  certificate_path 'cert.p12', 'password'
  identifier '1234567890'
end
```

### ✅ Automatická migrace
Při inicializaci klienta se použije správné URL podle `mode`:
- `:test` → `https://api-test.ksef.mf.gov.pl/v2`
- `:demo` → `https://api-demo.ksef.mf.gov.pl/v2`
- `:production` → `https://api.ksef.mf.gov.pl/v2`

### ⚠️ Custom URL
Pokud někdo explicitně nastavoval custom URL, měl by zkontrolovat:

```ruby
# Pokud máte toto:
client = KSEF.build do
  mode :test
  api_url 'https://ksef-test.mf.gov.pl/api/v2'  # DEPRECATED!
end

# Změňte na:
client = KSEF.build do
  mode :test
  api_url 'https://api-test.ksef.mf.gov.pl/v2'  # NOVÉ
end

# Nebo ještě lépe - použijte defaultní URL:
client = KSEF.build do
  mode :test  # Automaticky použije správné URL
end
```

## Testování migrace

### Spuštění testů
```bash
# Unit testy (včetně mode_spec.rb)
bundle exec rspec spec/value_objects/mode_spec.rb

# Všechny testy
bundle exec rspec
```

### Manuální ověření
```ruby
require './lib/ksef'

# Test URL
mode = KSEF::ValueObjects::Mode.new(:test)
puts mode.default_url
# => "https://api-test.ksef.mf.gov.pl/v2"

# Demo URL
mode = KSEF::ValueObjects::Mode.new(:demo)
puts mode.default_url
# => "https://api-demo.ksef.mf.gov.pl/v2"

# Production URL
mode = KSEF::ValueObjects::Mode.new(:production)
puts mode.default_url
# => "https://api.ksef.mf.gov.pl/v2"
```

## Timeline

- **Leden 2026** - KSeF oficiálně přešel na nové URL
- **19. Leden 2026 14:00** - Ruby KSeF gem aktualizován
- **19. Leden 2026 16:56** - VCR cassettes smazány (potřeba nahrát znovu)
- **Neurčito** - Staré URL pravděpodobně budou fungovat ještě nějakou dobu (backward compatibility)

## ⚠️ Akce potřebná: Nahrání nových VCR cassettes

VCR cassettes byly **smazány** kvůli migraci na nové URL.

### Co je potřeba udělat:

1. **Získat platný KSeF token:**
   ```bash
   ruby bin/get_test_token.rb cert.p12 password 1234567890
   ```
   Nebo přes webové rozhraní: https://ksef-test.mf.gov.pl/ → Ustawienia → Tokeny

2. **Nastavit token v testu:**
   ```ruby
   # spec/integration/invoice_sending_spec.rb
   let(:test_ksef_token) { "VÁŠ_PLATNÝ_TOKEN" }
   ```

3. **Nahrát nové cassettes:**
   ```bash
   bundle exec rspec spec/integration/invoice_sending_spec.rb
   ```

4. **Ověřit:**
   ```bash
   # Zkontroluj, že používá nové URL
   head -20 spec/fixtures/vcr_cassettes/invoice_sending/successful_fa3_highlevel.yml
   # Mělo by být: https://api-test.ksef.mf.gov.pl/v2
   ```

### Detailní návod:
📘 [VCR Recording Guide](VCR_RECORDING_GUIDE.md) - Kompletní návod krok za krokem

## Odkazy

- 📘 [Oficiální KSeF dokumentace](https://github.com/CIRFMF/ksef-docs)
- 📗 [API dokumentace](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- 📙 [Testovací prostředí - web](https://ksef-test.mf.gov.pl)
- 🔧 [Nový API server - test](https://api-test.ksef.mf.gov.pl/v2)
- 🎬 [VCR Recording Guide](VCR_RECORDING_GUIDE.md)

## Changelog

Kompletní seznam změn viz [CHANGELOG.md](CHANGELOG.md#unreleased---2026-01-19)

---

**Provedeno:** 19. ledna 2026
**Status:** ⚠️ Potřeba nahrát VCR cassettes
**Breaking changes:** ❌ Žádné (pro běžné použití)
