# Ruby KSeF Client - File Structure Overview 📁

## 📚 Documentation

### Main Documentation
- **[README.md](README.md)** - Complete documentation
- **[QUICK_START.md](QUICK_START.md)** - Quick start guide (5 minutes)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[INVOICE_SCHEMA.md](INVOICE_SCHEMA.md)** - FA(2) XML schema guide
- **[STATUS.md](STATUS.md)** - Detailed technical status (100% functional)
- **[FILES_OVERVIEW.md](FILES_OVERVIEW.md)** - This file
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

### Konfigurace
- **config.example.rb** - Příklad konfigurace
- **Gemfile** - Ruby dependencies
- **Gemfile.lock** - Locked dependencies

## 🔧 Nástroje (bin/)

- **bin/generate_test_cert.rb** - Generátor testovacích certifikátů
  - Support pro RSA/EC klíče
  - Self-signed certificates
  - Person/Organization types

- **bin/test_xades_manual.rb** - Manuální test XAdES autentizace
  - S loggingem
  - Polling pro status
  - Detailní výstup

- **bin/ksef_e2e_test.rb** - End-to-end test script
  - Registration + cert generation + auth
  - Kompletní flow

## 📖 Příklady (examples/)

- **examples/test_connection.rb** - Test připojení k KSeF
- **examples/debug_xades.rb** - Debug XAdES XML výstupu

## 🏗️ Core Library (lib/ksef/)

### Main Entry Point
- **lib/ksef.rb** - Main entry point, require all

### Actions
- **lib/ksef/actions/sign_document.rb** - XAdES signing (v1, deprecated)
- **lib/ksef/actions/sign_document_v2.rb** - XAdES signing (v2, active) ⭐
  - Exclusive canonicalization
  - RSA/ECDSA support
  - Complete XAdES-BES

### Factories
- **lib/ksef/factories/csr_factory.rb** - CSR generation
  - Pro enrollment proces
  - RSA/EC key generation

### HTTP Client
- **lib/ksef/http_client/client.rb** - HTTP client wrapper
  - Faraday-based
  - Authorization header management
  - Logger support

- **lib/ksef/http_client/response.rb** - Response wrapper
  - JSON parsing
  - Error handling

### Requests (API Handlers)

#### Auth Requests
- **lib/ksef/requests/auth/challenge_handler.rb** - GET challenge
- **lib/ksef/requests/auth/xades_signature_handler.rb** - XAdES auth ⭐
- **lib/ksef/requests/auth/ksef_token_handler.rb** - Token auth
- **lib/ksef/requests/auth/status_handler.rb** - Auth status check
- **lib/ksef/requests/auth/redeem_handler.rb** - Token redemption
- **lib/ksef/requests/auth/refresh_handler.rb** - Token refresh
- **lib/ksef/requests/auth/revoke_handler.rb** - Session revoke
- **lib/ksef/requests/auth/sessions_list_handler.rb** - List sessions
- **lib/ksef/requests/auth/sessions_revoke_handler.rb** - Revoke session

#### Invoice Requests
- **lib/ksef/requests/invoices/send_handler.rb** - Send invoice
- **lib/ksef/requests/invoices/status_handler.rb** - Invoice status
- **lib/ksef/requests/invoices/get_handler.rb** - Get invoice

#### Testdata Requests
- **lib/ksef/requests/testdata/register_person_handler.rb** - Register test person
- **lib/ksef/requests/testdata/person_create_handler.rb** - Create person
- **lib/ksef/requests/testdata/person_remove_handler.rb** - Remove person

#### Other Requests
- **lib/ksef/requests/security/public_key_handler.rb** - Get KSeF public keys
- **lib/ksef/requests/tokens/status_handler.rb** - Token status

### Resources (API Resources)
- **lib/ksef/resources/client.rb** - Main client ⭐
- **lib/ksef/resources/auth.rb** - Auth resource
- **lib/ksef/resources/invoices.rb** - Invoices resource
- **lib/ksef/resources/taxpayer.rb** - Taxpayer resource
- **lib/ksef/resources/sessions.rb** - Sessions resource
- **lib/ksef/resources/common.rb** - Common operations

### Security
- **lib/ksef/security/key_encryption.rb** - Key encryption (RSA-OAEP)

### Support
- **lib/ksef/support/utility.rb** - Utility functions (retry, etc.)

### Value Objects
- **lib/ksef/value_objects/access_token.rb** - Access token
- **lib/ksef/value_objects/refresh_token.rb** - Refresh token
- **lib/ksef/value_objects/ksef_token.rb** - KSeF token
- **lib/ksef/value_objects/certificate_path.rb** - Certificate path with validation
- **lib/ksef/value_objects/identifier.rb** - NIP/PESEL identifier
- **lib/ksef/value_objects/mode.rb** - Environment mode (test/demo/production)
- **lib/ksef/value_objects/nip.rb** - NIP value object
- **lib/ksef/value_objects/pesel.rb** - PESEL value object

### Core Classes
- **lib/ksef/config.rb** - Immutable configuration ⭐
- **lib/ksef/client_builder.rb** - Client builder pattern ⭐
  - Fluent API
  - Auto-authentication
- **lib/ksef/error.rb** - Error classes
- **lib/ksef/version.rb** - Version constant

## 📄 Source Documentation (sources/)

- **sources/ksef-docs-official/** - Oficiální KSeF dokumentace
  - certyfikaty-KSeF.md
  - uwierzytelnianie.md
  - dane-testowe-scenariusze.md
  - auth/testowe-certyfikaty-i-podpisy-xades.md
  - open-api.json

## 🧪 Generované soubory (Testing)

### Certificates
- **test_person.p12** - Test person certificate (EC)
- **test_ruby_fixed.p12** - Test cert with official NIP (EC)
- **test_ruby_rsa.p12** - Test cert with RSA key ⭐

### Debug files
- **debug_signed.xml** - Debug XAdES output

## ⭐ Klíčové soubory pro pochopení projektu

### Pro začátek:
1. **README_CZ.md** - Kompletní dokumentace
2. **QUICK_START_CZ.md** - Rychlý start
3. **bin/generate_test_cert.rb** - Certificate generator

### Pro implementaci:
4. **lib/ksef/client_builder.rb** - Client initialization
5. **lib/ksef/actions/sign_document_v2.rb** - XAdES signing
6. **lib/ksef/requests/auth/xades_signature_handler.rb** - Auth flow

### Pro debugging:
7. **bin/test_xades_manual.rb** - Manual test
8. **STATUS.md** - Technický status

## 📊 Struktura adresářů

```
ruby-ksef/
├── bin/                      # Executable scripts
├── examples/                 # Example scripts
├── lib/
│   └── ksef/
│       ├── actions/          # Business logic
│       ├── factories/        # Object factories
│       ├── http_client/      # HTTP infrastructure
│       ├── requests/         # API request handlers
│       ├── resources/        # API resources
│       ├── security/         # Cryptographic ops
│       ├── support/          # Utilities
│       └── value_objects/    # Domain objects
├── sources/                  # Documentation
└── [docs]                    # Generated documentation
```

## 🔑 Key Design Patterns

### Builder Pattern
```ruby
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'pass')
  .identifier('1234567890')
  .build
```

### Value Objects (Immutable)
```ruby
config = config.with_access_token(token)  # Returns new instance
```

### Handler Pattern
```ruby
response = ChallengeHandler.new(http_client).call
```

### Resource Pattern
```ruby
client.invoices.send_invoice(xml)
client.auth.challenge
```

## 📝 Coding Conventions

- **Naming**: Snake_case for files, PascalCase for classes
- **Organization**: One class per file
- **Immutability**: Value objects are immutable
- **Error handling**: Raise specific errors
- **Logging**: Via optional logger

## �� Jak číst projekt

### 1. Začni dokumentací
```
README_CZ.md → QUICK_START_CZ.md → STATUS.md
```

### 2. Prohlédni examples
```
examples/test_connection.rb
bin/generate_test_cert.rb
```

### 3. Pochop core
```
lib/ksef/client_builder.rb
lib/ksef/config.rb
lib/ksef/resources/client.rb
```

### 4. Prozkoumej implementation
```
lib/ksef/actions/sign_document_v2.rb
lib/ksef/requests/auth/xades_signature_handler.rb
lib/ksef/http_client/client.rb
```

---

**Total Files**: ~50+
**Lines of Code**: ~3000+
**Key Files**: 8-10
**Documentation Files**: 6
