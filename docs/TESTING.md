# Testing Guide

Tento dokument popisuje testovací strategii a integrační testy pro KSeF Ruby gem.

## Přehled testů

### Unit testy
Pokrývají jednotlivé komponenty:
- Actions (šifrování, podepisování, QR kódy)
- Factories (certifikáty, klíče)
- Invoice Schema (generování XML)
- Resources (API endpointy)
- Value Objects (NIP, tokeny, módy)
- Validator (validace dat)

```bash
# Spuštění unit testů
bundle exec rspec --exclude-pattern "spec/integration/**/*_spec.rb"
```

### Integrační testy 🚀

Integrační testy v `spec/integration/` testují komunikaci s reálným KSeF API.

**Klíčová vlastnost**: Používají [VCR gem](https://github.com/vcr/vcr) pro nahrávání HTTP interakcí.

#### Jak to funguje

1. **První spuštění** - s platným tokenem:
   - Test komunikuje s reálným KSeF test API
   - VCR automaticky zaznamenává všechny HTTP requesty a response
   - Cassettes se ukládají do `spec/fixtures/vcr_cassettes/`
   - Citlivá data (tokeny, NIP) jsou automaticky filtrována

2. **Další spuštění** - bez potřeby tokenu:
   - VCR přehrává zaznamenané HTTP interakce
   - Test běží **offline** a je **60x rychlejší** ⚡
   - Není potřeba platný token ani připojení k internetu

## Spuštění integračních testů

### První spuštění (nahrání cassettes)

Potřebujete **platný KSeF test token**:

```ruby
# spec/integration/invoice_sending_spec.rb
let(:test_ksef_token) do
  "VÁŠ_PLATNÝ_TOKEN"
end
```

**Kde získat token:**
1. Přihlaste se na https://ksef-test.mf.gov.pl/
2. Jděte do **Ustawienia** → **Tokeny**
3. Vytvořte nový token s oprávněními pro odesílání faktur
4. Token má formát: `datum-typ-číslo|identifikátor|hash`

**Spusťte testy:**
```bash
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

VCR nahraje HTTP interakce do:
```
spec/fixtures/vcr_cassettes/invoice_sending/
  └── successful_fa3_highlevel.yml
```

### Další spuštění (offline)

Jednoduše spusťte testy znovu:

```bash
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

✅ Funguje **bez** platného tokenu  
✅ Funguje **offline** (bez internetu)  
✅ **60x rychlejší** (0.06s místo 3.7s)

## Invoice Sending Test

Test `invoice_sending_spec.rb` ověřuje celý workflow odesílání faktury:

```ruby
it "successfully sends an invoice using high-level API" do
  # 1. Vytvoří FA(3) fakturu
  invoice = create_test_invoice
  xml = invoice.to_xml
  
  # 2. Vytvoří client s autentizací
  client = KSEF.build do
    mode :test
    identifier nip
    ksef_token token
  end
  
  # 3. Odešle fakturu (automatické šifrování!)
  response = client.send_invoice_online(xml)
  
  # 4. Ověří response
  expect(response).to have_key("referenceNumber")
  expect(response).to have_key("sessionReferenceNumber")
end
```

### Co test ověřuje

✅ **Autentizace** - pomocí KSeF tokenu  
✅ **Získání šifrovacího certifikátu** - z KSeF API  
✅ **Generování AES klíče** - náhodný 256-bit klíč  
✅ **Šifrování AES klíče** - RSA-OAEP s SHA-256  
✅ **Otevření online session** - se šifrováním  
✅ **Šifrování faktury** - AES-256-CBC  
✅ **Výpočet hash** - SHA-256 pro originál i šifrovaný obsah  
✅ **Odeslání faktury** - do KSeF systému  
✅ **Přijetí response** - s reference numbers

### Výsledek testu

```
✓ Invoice sent successfully!
  Invoice Reference: 20260116-EE-319390D000-C1162E4695-FD
  Session Reference: 20260116-SO-3193718000-8E6D363AC7-52

✓ Integration test PASSED - invoice sending works!
```

## VCR Konfigurace

### Filtrování citlivých dat

VCR automaticky filtruje:

```ruby
# spec/spec_helper.rb
VCR.configure do |config|
  # Filtruje tokeny v hlavičkách
  config.filter_sensitive_data("<KSEF_TOKEN>") { |interaction|
    interaction.request.headers["Sessiontoken"]&.first
  }
  
  # Filtruje tokeny v JSON body
  config.filter_sensitive_data("<KSEF_TOKEN>") do |interaction|
    if interaction.request.body.include?("ksefToken")
      interaction.request.body.match(/"ksefToken":\s*"([^"]+)"/)[1]
    end
  end
  
  # Filtruje NIP v URL
  config.filter_sensitive_data("<NIP>") do |interaction|
    if interaction.request.uri.include?("7980332920")
      "7980332920"
    end
  end
end
```

### Matching strategie

Pro integrační testy používáme:

```ruby
vcr: { 
  match_requests_on: [:method, :uri]  # Bez body!
}
```

**Proč ne body?**  
Body obsahuje `encryptedToken` který zahrnuje timestamp z challenge.  
Při každém běhu je jiný, takže VCR by nemohl najít matching cassette.

## Aktualizace cassettes

Když potřebujete znovu nahrát HTTP interakce (např. změnilo se API):

```bash
# 1. Smažte staré cassettes
rm -rf spec/fixtures/vcr_cassettes/invoice_sending/

# 2. Získejte nový platný token

# 3. Spusťte testy znovu
bundle exec rspec spec/integration/invoice_sending_spec.rb
```

VCR nahraje nové cassettes.

## Helper Scripts

### Získání test tokenu

Pro získání nového tokenu používejte helper script:

```bash
ruby bin/get_test_token.rb /path/to/cert.p12 password NIP
```

Script:
1. Autentizuje se pomocí certifikátu
2. Vytvoří nový KSeF token
3. Vypíše token pro použití v testech

## Coverage

Spusťte testy s coverage reportem:

```bash
COVERAGE=1 bundle exec rspec
```

Coverage report se vygeneruje do `coverage/index.html`.

## Continuous Integration

Pro CI prostředí:

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: bundle exec rspec
  env:
    # Testy běží s VCR cassettes (offline)
    VCR_RECORD_MODE: none
```

**Poznámka**: V CI není potřeba platný token, protože VCR cassettes jsou commitnuté do repozitáře.

## Troubleshooting

### "Nieprawidłowe wyzwanie autoryzacyjne"

Token je neplatný nebo expirovaný.

**Řešení**:
1. Získejte nový token z KSeF test prostředí
2. Aktualizujte token v testu
3. Smažte cassettes a spusťte test znovu

### "VCR cassette not found"

Test běží poprvé a VCR ještě nemá nahrané cassettes.

**Řešení**: Spusťte test s platným tokenem (viz výše).

### "UnhandledHTTPRequestError"

VCR nemůže najít matching cassette nebo má zakázáno nahrávat nové requesty.

**Řešení**:
```ruby
# Povolte nahrávání nových epizod
vcr: { record: :new_episodes }
```

### Chyba při šifrování

**Řešení**: Ujistěte se, že máte OpenSSL:
```bash
ruby -ropenssl -e 'puts OpenSSL::VERSION'
```

## Best Practices

### ✅ DO

- Používejte VCR pro integrační testy
- Commitujte cassettes do repozitáře
- Filtrujte citlivá data (tokeny, hesla, NIP)
- Testujte s testovacím prostředím KSeF
- Pravidelně aktualizujte cassettes (při změnách API)

### ❌ DON'T

- Necommitujte reálné tokeny nebo hesla
- Nespouštějte testy proti production API
- Nevytvářejte reálné faktury v testech
- Nepoužívejte reálná NIP čísla v cassettes

## Další informace

- [VCR dokumentace](https://github.com/vcr/vcr)
- [RSpec dokumentace](https://rspec.info/)
- [KSeF API dokumentace](../sources/ksef-docs-official/)
- [Integration test README](../spec/integration/README.md)
