# ⚠️ VCR Cassettes byly smazány

**Datum:** 19. ledna 2026, 16:56
**Důvod:** Migrace na nové KSeF API URL

## Co se stalo

V rámci aktualizace na nové KSeF API URL byly **všechny VCR cassettes smazány**.

### Proč?

KSeF oficiálně přešel z deprecated URL:
- ❌ `https://ksef-test.mf.gov.pl/api/v2`

Na nové URL:
- ✅ `https://api-test.ksef.mf.gov.pl/v2`

Staré cassettes obsahovaly deprecated URL, proto bylo lepší je smazat a nahrát znovu s novými URL.

## Co je potřeba udělat?

### Pro běžné uživatele gemu:
👉 **NIC!** Gem funguje normálně, cassettes jsou jen pro vývojáře/testy.

### Pro vývojáře, kteří chtějí spouštět integrační testy:

**Potřebuješ nahrát nové cassettes s platným KSeF tokenem:**

#### Rychlý postup:

```bash
# 1. Získej token
ruby bin/get_test_token.rb cert.p12 password 1234567890

# 2. Nastav v testu (spec/integration/invoice_sending_spec.rb)
let(:test_ksef_token) { "VÁŠ_TOKEN_ZDE" }

# 3. Spusť test (nahraje cassettes automaticky)
bundle exec rspec spec/integration/invoice_sending_spec.rb

# 4. Ověř
ls -la spec/fixtures/vcr_cassettes/invoice_sending/
# Měl bys vidět: successful_fa3_highlevel.yml
```

#### Detailní návod:

📘 **[docs/VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md)** - Kompletní krok-za-krokem návod

## Dokumentace

Byly vytvořeny/aktualizovány následující dokumenty:

- 📘 [VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md) - **NOVÝ** - Jak nahrát cassettes
- 📗 [API_URL_MIGRATION.md](docs/API_URL_MIGRATION.md) - Aktualizováno s VCR info
- 📙 [MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md) - Aktualizován status
- 🎬 [spec/fixtures/vcr_cassettes/README.md](spec/fixtures/vcr_cassettes/README.md) - **NOVÝ** - README v cassettes složce

## FAQ

### Q: Musím něco změnit ve svém kódu?
**A:** Ne! Pokud jen používáš gem, nic měnit nemusíš.

### Q: Nefungují mi testy
**A:** Pokud spouštíš integrační testy (`spec/integration/`), potřebuješ nahrát nové cassettes (viz návod výše).

### Q: Unit testy fungují?
**A:** Ano! Unit testy (`spec/` kromě `spec/integration/`) fungují normálně.

### Q: Kdy budou cassettes znovu nahrány?
**A:** Až někdo s platným KSeF tokenem spustí integrační testy. Pak budou commitnuty do repozitáře.

### Q: Mohu použít staré cassettes?
**A:** Ne, obsahují deprecated URL. Lepší je nahrát nové.

## Status

| Komponenta | Status |
|------------|--------|
| Kód aplikace | ✅ Aktualizován |
| Dokumentace | ✅ Aktualizována |
| Unit testy | ✅ Fungují |
| VCR cassettes | ⏳ Potřeba nahrát |
| Integrační testy | ⏳ Vyžadují cassettes |

---

**Pro otázky nebo problémy, viz:**
📘 [docs/VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md)
