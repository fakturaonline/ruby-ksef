# VCR Cassettes

## ⚠️ Cassettes byly smazány (19.1.2026)

Všechny VCR cassettes byly smazány kvůli migraci na nové KSeF API URL.

## 🎯 Co je potřeba udělat

### Rychlý návod:

1. **Získej KSeF token:**
   ```bash
   ruby bin/get_test_token.rb cert.p12 password 1234567890
   ```

2. **Nastav v testu:**
   ```ruby
   # spec/integration/invoice_sending_spec.rb
   let(:test_ksef_token) { "VÁŠ_TOKEN" }
   ```

3. **Nahraj cassettes:**
   ```bash
   bundle exec rspec spec/integration/invoice_sending_spec.rb
   ```

### Detailní návod:
📘 **[Kompletní VCR Recording Guide](../../../docs/VCR_RECORDING_GUIDE.md)**

## 📦 Co budou cassettes obsahovat

Po nahrání budou cassettes používat **nové API URL:**
- ✅ `https://api-test.ksef.mf.gov.pl/v2`

Místo deprecated:
- ❌ `https://ksef-test.mf.gov.pl/api/v2`

## 🔒 Bezpečnost

VCR automaticky filtruje citlivá data:
- Tokeny → `<KSEF_TOKEN>`
- NIP → `<NIP>`

Před commitem vždy zkontroluj:
```bash
grep -r "20260119-" .  # Nemělo by najít tokeny
```

---

**Smazáno:** 19. ledna 2026, 16:56
**Důvod:** Migrace na nové API URL
**Status:** Připraveno k nahrání
