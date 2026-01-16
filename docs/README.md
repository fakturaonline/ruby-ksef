# Ruby KSeF Client 🇵🇱

**Kompletní Ruby klient pro Krajowy System e-Faktur (KSeF)** - oficiální polský systém elektronických faktur.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**KSeF API Version**: 2.0 RC5.4 (October 15, 2025)
**Gem Version**: 1.2.0 (RC5.4 compatible)

## 📋 Obsah

- [O projektu](#o-projektu)
- [Funkce](#funkce)
- [Instalace](#instalace)
- [Rychlý start](#rychlý-start)
- [Autentizace](#autentizace)
- [Generování testovacích certifikátů](#generování-testovacích-certifikátů)
- [Příklady použití](#příklady-použití)
- [Dokumentace](#dokumentace)
- [Testování](#testování)
- [Současný stav](#současný-stav)

## O projektu

Ruby KSeF Client je plně funkční implementace klienta pro API v2 Krajowego Systemu e-Faktur. Poskytuje elegantní Ruby rozhraní pro:

- ✅ Autentizaci pomocí certifikátů (XAdES)
- ✅ Autentizaci pomocí KSeF tokenů
- ✅ Správu faktur (odesílání, stahování, dotazování)
- ✅ Správu sessions a tokenů
- ✅ Podpisování XML dokumentů (XAdES-BES)
- ✅ Generování testovacích certifikátů

## Funkce

### ✨ Nové v RC5.4

- **PEPPOL faktury**: Podpora PEF (3) a PEF_KOR (3) formulářů
- **Multi-context autentizace**: Nip, InternalId, PeppolId typy
- **Pokročilé řazení**: sortOrder parametr v dotazech metadat
- **Export metadata**: _metadata.json v exportech
- **Rozšířená oprávnění**: VatUeManage token permission
- **MB limity**: Nové standardizované limity (MiB deprecated)

### 🔐 Autentizace

- **XAdES Signature**: Autentizace pomocí kvalifikovaného elektronického podpisu
- **KSeF Token**: Autentizace pomocí tokenů vydaných KSeF
- **Automatická správa tokenů**: Access tokens, refresh tokens
- **Session management**: Správa aktivních sessions
- **Multi-context**: Podpora Nip, InternalId, PeppolId kontextů ✨

### 📄 Správa faktur

- Odesílání faktur do KSeF
- Stahování faktur (FA, XML, PDF)
- Dotazování na status faktur
- Hromadné operace

### 🛡️ Bezpečnost

- XAdES-BES digital signatures
- X.509 certificate handling
- TLS/SSL komunikace
- Token encryption (RSA-OAEP)

### 🔧 Nástroje

- Generátor testovacích certifikátů (RSA/EC)
- CSR factory pro enrollment
- Validace NIP/PESEL
- Logger integration

## Instalace

### Požadavky

- Ruby 3.0+
- OpenSSL 3.0+
- Bundler

### Instalace závislostí

```bash
bundle install
```

### Konfigurace

Zkopírujte příklad konfigurace:

```bash
cp config.example.rb config.rb
```

Upravte `config.rb` podle vašich potřeb.

## Rychlý start

### 1. Generování testovacího certifikátu

Pro testovací prostředí můžete vygenerovat self-signed certifikát:

```bash
# RSA certifikát (doporučeno pro kompatibilitu)
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "Jan Kowalski" \
  -o test_cert.p12 \
  -p test123 \
  -k rsa

# EC certifikát (modernější, menší klíče)
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "Jan Kowalski" \
  -o test_cert.p12 \
  -p test123 \
  -k ec
```

**Důležité**: Self-signed certifikáty jsou **POUZE** pro testovací prostředí!

### 2. Inicializace klienta

```ruby
require 'ksef'

# Klient s certifikátem
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('test_cert.p12', 'test123')
  .identifier('1234567890')  # NIP nebo PESEL
  .build

# Klient s KSeF tokenem
client = KSEF::ClientBuilder.new
  .mode(:test)
  .ksef_token('your-ksef-token')
  .identifier('1234567890')
  .build
```

### 3. Použití API

```ruby
# Poslat fakturu
invoice_xml = File.read('invoice.xml')
response = client.invoices.send_invoice(invoice_xml)
puts "Invoice sent: #{response['referenceNumber']}"

# Získat status faktury
status = client.invoices.status(reference_number)
puts "Status: #{status['processingCode']}"

# Stáhnout fakturu
invoice = client.invoices.get_invoice(ksef_reference_number)
puts invoice
```

## Autentizace

### XAdES Certificate Authentication

```ruby
# 1. Vygeneruj nebo získej certifikát
# Pro produkci: získej kvalifikovaný certifikát od důvěryhodné CA
# Pro testing: vygeneruj self-signed certifikát (viz výše)

# 2. Inicializuj klienta
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'passphrase')
  .identifier('1234567890')
  .build

# 3. Klient se automaticky autentizuje
# - Získá challenge
# - Sestaví AuthTokenRequest
# - Podepíše XAdES
# - Odešle signed XML
# - Čeká na completion
# - Získá access token
```

### KSeF Token Authentication

```ruby
client = KSEF::ClientBuilder.new
  .mode(:test)
  .ksef_token('your-ksef-token')
  .identifier('1234567890')
  .build
```

### Manuální autentizace

```ruby
# Získej challenge
challenge = client.auth.challenge

# Autentizuj se
# ... (pomocí certifikátu nebo tokenu)

# Obnov token
new_token = client.auth.refresh
```

## Generování testovacích certifikátů

Ruby KSeF Client obsahuje nástroj pro generování self-signed certifikátů pro testování.

### Základní použití

```bash
ruby bin/generate_test_cert.rb [options]
```

### Možnosti

```
-t, --type TYPE              Certificate type (person, organization)
-n, --nip NIP                NIP number (required)
    --name NAME              Name or organization name
-o, --output FILE            Output PKCS12 file (default: test_cert.p12)
-p, --passphrase PASS        PKCS12 passphrase (default: test123)
-k, --key-type TYPE          Key type: rsa or ec (default: rsa)
-h, --help                   Show help
```

### Příklady

```bash
# Fyzická osoba s RSA
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "Jan Kowalski" \
  -o person.p12 \
  -p mypass

# Organizace s EC klíčem
ruby bin/generate_test_cert.rb \
  -t organization \
  -n 9876543210 \
  --name "Test Firma sp. z o.o." \
  -o company.p12 \
  -k ec
```

### Struktura certifikátu

Generované certifikáty obsahují:

**Pro fyzickou osobu (person):**
- `C` (Country): PL
- `GN` (GivenName): Křestní jméno
- `SN` (Surname): Příjmení
- `serialNumber`: TINPL-{NIP}
- `CN` (CommonName): Celé jméno

**Pro organizaci (organization):**
- `C` (Country): PL
- `O` (Organization): Název firmy
- `serialNumber`: TINPL-{NIP}
- `CN` (CommonName): Název firmy

## Příklady použití

### Poslání faktury

```ruby
require 'ksef'

# Inicializuj klienta
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'pass')
  .identifier('1234567890')
  .build

# Načti FA XML
invoice_xml = File.read('fa_invoice.xml')

# Pošli fakturu
response = client.invoices.send_invoice(invoice_xml)

puts "✓ Invoice sent!"
puts "Reference: #{response['referenceNumber']}"
puts "Element number: #{response['elementReferenceNumber']}"

# Čekej na zpracování
reference = response['referenceNumber']
status = nil

30.times do
  status = client.invoices.status(reference)
  break if status['processingCode'] == 200
  sleep 2
end

if status['processingCode'] == 200
  puts "✓ Invoice processed successfully!"
  puts "KSeF number: #{status['ksefReferenceNumber']}"
else
  puts "✗ Processing failed: #{status['processingDescription']}"
end
```

### Stažení faktury

```ruby
# Podle KSeF reference number
invoice = client.invoices.get_invoice('1234567890-20241017-1234567890ABCD-12')

# Ulož XML
File.write('downloaded_invoice.xml', invoice)
```

### Správa sessions

```ruby
# Získej aktivní sessions
sessions = client.auth.sessions_list

sessions['sessions'].each do |session|
  puts "Session: #{session['referenceNumber']}"
  puts "Created: #{session['createdAt']}"
end

# Zruš session
client.auth.sessions_revoke(session_reference_number)

# Zruš aktuální session
client.auth.revoke
```

## Dokumentace

### Oficiální KSeF dokumentace

- 📘 [KSeF Docs (GitHub)](https://github.com/CIRFMF/ksef-docs)
- 📗 [API v2 OpenAPI](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- 📙 [Testovací prostředí](https://ksef-test.mf.gov.pl)

### Struktura projektu

```
ruby-ksef/
├── lib/
│   └── ksef/
│       ├── actions/           # XAdES signing, validation
│       ├── factories/          # CSR, certificate factories
│       ├── http_client/        # HTTP client wrapper
│       ├── requests/           # API request handlers
│       ├── resources/          # API resources (invoices, auth, etc.)
│       ├── security/           # Cryptographic operations
│       ├── support/            # Utilities
│       └── value_objects/      # Domain objects
├── bin/
│   ├── generate_test_cert.rb  # Certificate generator
│   └── ksef_e2e_test.rb       # E2E test script
├── examples/
│   ├── test_connection.rb     # Connection test
│   └── debug_xades.rb         # XAdES debugging
└── sources/
    └── ksef-docs-official/    # Official documentation
```

### API Resources

```ruby
client.auth          # Authentication operations
client.invoices      # Invoice operations
client.taxpayer      # Taxpayer information
client.sessions      # Session management
client.common        # Common operations
```

## Testování

### Spuštění testů

```bash
# Unit tests
bundle exec rspec

# E2E test
ruby bin/ksef_e2e_test.rb

# Connection test
ruby examples/test_connection.rb
```

### Debug XAdES signature

```bash
ruby examples/debug_xades.rb
```

## Současný stav

### ✅ Co funguje

1. **XAdES Signing**
   - ✅ Správná struktura XAdES-BES
   - ✅ Exclusive canonicalization (C14N)
   - ✅ RSA-SHA256 a ECDSA-SHA256 signatures
   - ✅ Correct digests pro document a SignedProperties
   - ✅ Transforms (enveloped-signature + xml-exc-c14n)

2. **Certificate Generation**
   - ✅ RSA 2048-bit keys
   - ✅ EC P-256 keys
   - ✅ Self-signed certificates pro testing
   - ✅ Správné DN attributes (C, GN, SN, serialNumber, CN)
   - ✅ PKCS#12 export

3. **Authentication Flow**
   - ✅ Challenge request (POST /auth/challenge)
   - ✅ AuthTokenRequest XML building
   - ✅ XAdES signature signing
   - ✅ XAdES signature submission (POST /auth/xades-signature)
   - ✅ Response 202 Accepted - **SIGNED XML IS VALID!** 🎉

### ⚠️ Known Issues

1. **Auth Status Check**
   - Status endpoint vrací 401 Unauthorized
   - Možné příčiny:
     - Self-signed certifikáty s náhodným NIPem vyžadují registraci v KSeF test prostředí
     - AuthenticationToken je platný, ale certifikát není důvěryhodný pro daný NIP
   - Workaround: Použít oficiální test NIP nebo registrovaný certifikát

2. **Testovací data**
   - KSeF test prostředí má specifické test NIPs
   - Self-signed certs fungují v C# klientovi, ale možná vyžadují specifický setup

### 🚀 Next Steps

1. **Pro produkční použití:**
   - Získej kvalifikovaný certifikát od důvěryhodné CA
   - Použij registrovaný NIP
   - Testuj na demo prostředí před produkcí

2. **Pro další vývoj:**
   - Implementovat enrollment proces pro získání KSeF certifikátů
   - Přidat podporu pro batch operations
   - Rozšířit invoice API o všechny operace
   - Přidat podporu pro notifikace

## Přispívání

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
git clone https://github.com/yourusername/ruby-ksef.git
cd ruby-ksef
bundle install
```

### Running Tests

```bash
bundle exec rspec
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Zdroje

- [Oficiální KSeF dokumentace](https://github.com/CIRFMF/ksef-docs)
- [KSeF C# Client](https://github.com/CIRFMF/ksef-client-csharp)
- [KSeF Java SDK](https://github.com/CIRFMF/ksef-client-java)
- [KSeF API v2](https://ksef-test.mf.gov.pl/docs/v2/index.html)

## Kontakt

Pro otázky a podporu:
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/ruby-ksef/issues)
- 📧 Email: your.email@example.com

---

**⚡ Made with Ruby in Czech Republic**
