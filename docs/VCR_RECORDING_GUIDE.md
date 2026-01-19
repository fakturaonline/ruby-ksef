# Návod pro nahrání VCR Cassettes

## 🎯 Účel

Tento dokument popisuje, jak nahrát nové VCR cassettes s aktuálními API URL po migraci na nové KSeF API endpointy.

## 📋 Přehled

**Stav:** Všechny VCR cassettes byly smazány 19.1.2026
**Důvod:** Migrace z deprecated URL na nové API URL
**Akce potřebná:** Nahrání nových cassettes s platným KSeF tokenem

## 🔐 Krok 1: Získání KSeF tokenu

Potřebuješ **platný testovací KSeF token**. Máš dvě možnosti:

### Možnost A: Pomocě helper skriptu (s certifikátem)

Pokud máš testovací certifikát:

```bash
# Vygeneruj nebo použij existující certifikát
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "Test User" \
  -k rsa \
  -o test_cert.p12 \
  -p password123

# Získej token pomocí certifikátu
ruby bin/get_test_token.rb test_cert.p12 password123 1234567890
```

Script vypíše token, který vypadá například takto:
```
20260119-TK-1234567890-ABCDEF123456-01|identifier|hash
```

### Možnost B: Přes webové rozhraní

1. Přihlaš se na https://ksef-test.mf.gov.pl/ (webové rozhraní)
2. Jdi do **Ustawienia** → **Tokeny**
3. Vytvoř nový token s oprávněními:
   - `InvoiceRead`
   - `InvoiceWrite`
   - `InvoiceQuery`
4. Zkopíruj vygenerovaný token

## 📝 Krok 2: Konfigurace testů

### Pro integrační test (invoice_sending_spec.rb)

Otevři `spec/integration/invoice_sending_spec.rb` a aktualizuj:

```ruby
let(:test_nip) do
  "1234567890"  # Tvůj testovací NIP
end

let(:test_ksef_token) do
  "20260119-TK-1234567890-ABCDEF123456-01|identifier|hash"  # Tvůj token
end
```

### Pro ostatní testy

Většina testů v `spec/` nepoužívá integrační testy, ale pokud některé ano, nastav token podobně.

## 🎬 Krok 3: Nahrání VCR cassettes

### Integrační test (hlavní)

```bash
# Nahraje cassettes pro invoice sending
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

**Co se stane:**
1. Test se připojí k **novému** API: `https://api-test.ksef.mf.gov.pl/v2`
2. VCR zaznamená všechny HTTP requesty/responses
3. Cassette se uloží do `spec/fixtures/vcr_cassettes/invoice_sending/successful_fa3_highlevel.yml`
4. Token a NIP budou automaticky vyfiltrované (nahrazené `<KSEF_TOKEN>` a `<NIP>`)

**Očekávaný výstup:**
```
Invoice Sending
  ✓ successfully sends an invoice using high-level API

Finished in 4.23 seconds
1 example, 0 failures
```

### Další testy (pokud potřeba)

Pokud existují další testy, které potřebují VCR cassettes, spusť je:

```bash
# Spustí všechny testy (nahraje všechny potřebné cassettes)
bundle exec rspec

# Nebo specifický test
bundle exec rspec spec/specific_test_spec.rb
```

## ✅ Krok 4: Ověření

### Zkontroluj nahrané cassettes

```bash
# Zobraz seznam nahraných cassettes
ls -la spec/fixtures/vcr_cassettes/
ls -la spec/fixtures/vcr_cassettes/invoice_sending/
```

### Ověř správné URL

Otevři některou cassette a zkontroluj URL:

```bash
head -20 spec/fixtures/vcr_cassettes/invoice_sending/successful_fa3_highlevel.yml
```

Měl bys vidět:
```yaml
- request:
    method: post
    uri: https://api-test.ksef.mf.gov.pl/v2/auth/challenge  # ✅ Nové URL!
```

### Spusť testy offline

Smažeš-li token z testu, cassettes by měly fungovat offline:

```ruby
# spec/integration/invoice_sending_spec.rb
let(:test_ksef_token) do
  "dummy-token"  # VCR přehrává nahrané interakce
end
```

```bash
# Mělo by fungovat bez připojení
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

## 🔒 Bezpečnost

### Filtrování citlivých dat

VCR automaticky filtruje:
- ✅ KSeF tokeny v hlavičkách (`SessionToken`)
- ✅ KSeF tokeny v JSON body (`ksefToken`)
- ✅ NIP čísla v URL a body
- ✅ Certifikáty a soukromé klíče

Konfigurace je v `spec/spec_helper.rb`:

```ruby
VCR.configure do |config|
  config.filter_sensitive_data("<KSEF_TOKEN>") { |interaction|
    interaction.request.headers["Sessiontoken"]&.first
  }
  # ... další filtry
end
```

### Před commitem

Vždy zkontroluj cassettes před commitem:

```bash
# Vyhledej případné nezafiltrované tokeny
grep -r "20260119-TK" spec/fixtures/vcr_cassettes/
grep -r "1234567890" spec/fixtures/vcr_cassettes/  # NIP

# Nemělo by nic najít (vše by mělo být <KSEF_TOKEN> a <NIP>)
```

## 🐛 Troubleshooting

### Error: "Neprawidłowe wyzwanie autoryzacyjne"

**Problém:** Token je neplatný nebo expirovaný.

**Řešení:**
1. Vytvoř nový token (viz Krok 1)
2. Smaž cassettes: `rm -rf spec/fixtures/vcr_cassettes/*.yml`
3. Spusť test znovu

### Error: "VCR cassette not found"

**Problém:** Cassette ještě neexistuje.

**Řešení:** To je OK - test nahraje novou cassette při prvním spuštění.

### Error: "Connection refused"

**Problém:** API není dostupné nebo špatné URL.

**Řešení:**
1. Zkontroluj, že používáš správné URL: `https://api-test.ksef.mf.gov.pl/v2`
2. Ověř síťové připojení:
   ```bash
   curl https://api-test.ksef.mf.gov.pl/v2/auth/challenge -X POST \
     -H "Content-Type: application/json" -d "{}"
   ```

### Test je příliš pomalý

**Problém:** První nahrání trvá déle (3-5 sekund).

**Řešení:** To je normální - další spuštění budou rychlá (0.05s) díky VCR.

## 📊 Statistiky

Po úspěšném nahrání by měly být cassettes:

```bash
$ find spec/fixtures/vcr_cassettes -name "*.yml" | wc -l
1  # (nebo více, podle počtu testů)

$ du -sh spec/fixtures/vcr_cassettes/
40K    spec/fixtures/vcr_cassettes/
```

## 🎯 Shrnutí

1. ✅ **Smazány staré cassettes** (19.1.2026)
2. ⏳ **Získat KSeF token** (pomocí scriptu nebo webového rozhraní)
3. ⏳ **Nastavit token v testech** (`spec/integration/invoice_sending_spec.rb`)
4. ⏳ **Spustit testy** (`bundle exec rspec spec/integration/`)
5. ⏳ **Ověřit nové cassettes** (zkontrolovat URL)
6. ⏳ **Commitnout** (po ověření bezpečnosti)

## 📚 Související dokumenty

- 📘 [Testovací dokumentace](TESTING.md)
- 📗 [Migrace API URL](API_URL_MIGRATION.md)
- 📙 [Integrační testy README](../spec/integration/README.md)

---

**Připraveno:** 19. ledna 2026
**Status:** Připraveno k nahrání nových cassettes s novými API URL
