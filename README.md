# KSEF Ruby Client

Complete Ruby implementation for **KSEF (Krajowy System e-Faktur)** - Polish e-invoicing system.

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-ruby.svg)](https://www.ruby-lang.org/en/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

- ✅ **Type-safe** - leverages Ruby 3+ features and value objects
- ✅ **Immutable** - all objects are immutable for safety
- ✅ **Fluent API** - clean builder pattern
- ✅ **Auto-authentication** - supports certificates and tokens
- ✅ **Auto-refresh tokens** - automatic access token renewal
- ✅ **Encryption** - AES-256-CBC for invoices
- ✅ **Async batch processing** - parallel invoice sending
- ✅ **Comprehensive** - all KSEF API v2 endpoints

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ksef'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install ksef
```

## Quick Start

### Basic Setup with Certificate

```ruby
require 'ksef'

# Build client with auto-authentication
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "passphrase"
  identifier "1234567890" # Your NIP
  random_encryption_key   # Generate random AES key for invoice encryption
end

# Client is ready to use!
```

### Using Existing Tokens

```ruby
client = KSEF.build do
  mode :production
  access_token "your_access_token", expires_at: Time.now + 3600
  refresh_token "your_refresh_token"
  identifier "1234567890"
end
```

## Usage Examples

### Authentication

#### Get Challenge

```ruby
challenge = client.auth.challenge
# => { "challenge" => "...", "timestamp" => "..." }
```

#### Check Status

```ruby
status = client.auth.status(reference_number)
```

#### Manual Token Refresh

```ruby
new_token = client.auth.refresh
```

### Online Invoice Sending

```ruby
# Send single invoice
response = client.sessions.send_online(
  invoice_hash: "...",
  invoice_payload: invoice_xml
)

reference_number = response["referenceNumber"]

# Wait for processing (with retry)
status = KSEF::Support::Utility.retry(backoff: 10, retry_until: 120) do
  result = client.sessions.status(reference_number)
  result["status"]["code"] == 200 ? result : nil
end

ksef_number = status["ksefNumber"]
puts "Invoice sent! KSEF Number: #{ksef_number}"
```

### Download UPO (Official Receipt Confirmation)

After sending an invoice, you can download the **UPO** (Urzędowe Poświadczenie Odbioru) - official receipt confirmation signed by KSeF:

```ruby
# Download UPO by KSEF number
upo = client.sessions.upo_by_ksef_number(session_reference_number, ksef_number)

# Download UPO by invoice reference number
upo = client.sessions.upo_by_invoice_reference(session_reference_number, invoice_reference_number)

# Download UPO by UPO reference number
upo = client.sessions.upo(session_reference_number, upo_reference_number)

# UPO contains signed XML document
puts upo["upo"] # XML content
```

### Generate QR Code for Invoice

```ruby
# Generate QR code with UPO data
qr_generator = KSEF::Actions::GenerateQRCode.new
qr_code = qr_generator.call(
  ksef_number: ksef_number,
  timestamp: upo["timestamp"],
  amount: invoice_total
)

# qr_code is a binary PNG image - save or embed in PDF
File.write("invoice_qr.png", qr_code)
```

### Complete Invoice Workflow

```ruby
# 1. Send invoice
response = client.sessions.send_online(
  invoice_hash: calculate_hash(invoice_xml),
  invoice_payload: Base64.strict_encode64(invoice_xml)
)

session_ref = response["referenceNumber"]

# 2. Wait for processing
status = KSEF::Support::Utility.retry(backoff: 5, retry_until: 60) do
  result = client.sessions.status(session_ref)
  result["status"]["code"] == 200 ? result : nil
end

ksef_number = status["ksefNumber"]

# 3. Download UPO
upo = client.sessions.upo_by_ksef_number(session_ref, ksef_number)

# 4. Generate QR code
qr_generator = KSEF::Actions::GenerateQRCode.new
qr_code = qr_generator.call(
  ksef_number: ksef_number,
  timestamp: upo["timestamp"]
)

# 5. Close session
client.sessions.close_online(session_ref)

puts "✅ Invoice #{ksef_number} sent, UPO received, QR generated!"
```

### Query Session Invoices

```ruby
# List all invoices in session
invoices = client.sessions.invoices(session_ref)

# Get specific invoice details
invoice = client.sessions.invoice(session_ref, invoice_ref)

# List failed invoices
failed = client.sessions.failed_invoices(session_ref)

# List online session invoices
online_invoices = client.sessions.online_invoices(session_ref)
```

### Batch Invoice Sending

```ruby
# Send multiple invoices at once
response = client.sessions.send_batch(
  form_code: "FA (3)",
  invoices: [invoice1_xml, invoice2_xml, invoice3_xml]
)

# Check batch status
status = client.sessions.status(response["referenceNumber"])
```

### Invoice Download & Decryption

```ruby
# Download invoice (encrypted if encryption key was set)
encrypted_invoice = client.invoices.download(ksef_number)

# Decrypt invoice
decryptor = KSEF::Actions::DecryptDocument.new(client.encryption_key)
invoice_xml = decryptor.call(encrypted_invoice)

puts invoice_xml
```

### Invoice Query

```ruby
# Query invoices by criteria
results = client.invoices.query(
  from_date: "2025-01-01",
  to_date: "2025-01-31",
  invoice_type: "sent"
)

results["invoices"].each do |invoice|
  puts "#{invoice['ksefNumber']}: #{invoice['amount']} PLN"
end
```

### Certificate Management

```ruby
# Get enrollment data
enrollment_data = client.certificates.enrollment_data

# Generate CSR (placeholder - you need to implement full CSR generation)
# csr = generate_csr(enrollment_data)

# Send enrollment request
response = client.certificates.enroll(
  certificate_name: "My KSEF Certificate",
  certificate_type: "Authentication",
  csr: Base64.strict_encode64(csr_der)
)

reference_number = response["referenceNumber"]

# Wait for certificate generation
status = KSEF::Support::Utility.retry(backoff: 10, retry_until: 300) do
  result = client.certificates.enrollment_status(reference_number)
  result["status"]["code"] == 200 ? result : nil
end

# Retrieve certificate
certificates = client.certificates.retrieve([status["certificateSerialNumber"]])
certificate_der = Base64.decode64(certificates["certificates"][0]["certificate"])
```

### QR Code Generation

```ruby
# For online invoice (after sending)
qr_generator = KSEF::Actions::GenerateQrCode.new(
  nip: "1234567890",
  invoice_date: Date.today,
  ksef_number: "1234567890-20250115-ABCDEF123456-78"
)

qr_code = qr_generator.call
File.write("invoice_qr.svg", qr_code[:svg])
File.binwrite("invoice_qr.png", qr_code[:png].to_s)
```

### Encryption & Decryption

```ruby
# Generate encryption key
encryption_key = KSEF::ValueObjects::EncryptionKey.random

# IMPORTANT: Save this key! You'll need it to decrypt invoices
puts "Key: #{Base64.strict_encode64(encryption_key.key)}"
puts "IV: #{Base64.strict_encode64(encryption_key.iv)}"

# Encrypt document
encryptor = KSEF::Actions::EncryptDocument.new(encryption_key)
encrypted = encryptor.call(invoice_xml)

# Decrypt document
decryptor = KSEF::Actions::DecryptDocument.new(encryption_key)
decrypted = decryptor.call(encrypted)
```

## Configuration

### Modes

```ruby
# Test environment (default NIP: 1111111111)
mode :test

# Demo environment
mode :demo

# Production environment
mode :production
```

### Logging

```ruby
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

client = KSEF.build do
  logger logger
  # ... other config
end
```

### Custom HTTP Client

The gem uses Faraday for HTTP requests. You can customize it:

```ruby
# Default timeout is 60s, you can adjust in HttpClient::Client
```

## Architecture

This Ruby gem follows the same architecture as the PHP client:

```
┌─────────────────────────────────────┐
│         ClientBuilder               │
│  (Fluent API for configuration)     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       Resources::Client             │
│  (Root resource, auto-refresh)      │
└──────┬──────────────────────────────┘
       │
       ├──► Auth (authentication)
       ├──► Sessions (invoice operations)
       ├──► Invoices (query, download)
       ├──► Certificates (cert management)
       ├──► Tokens (token management)
       └──► Security (public keys)
              │
              ▼
       ┌──────────────────┐
       │  Request Handlers │
       │  (HTTP operations) │
       └────────┬───────────┘
                │
                ▼
       ┌──────────────────┐
       │   HttpClient      │
       │  (Faraday wrapper)│
       └───────────────────┘
```

### Key Components

- **ClientBuilder** - Fluent interface for building configured client
- **Config** - Immutable configuration object
- **Resources** - API endpoint wrappers (Auth, Sessions, Invoices, etc.)
- **Requests** - Handler classes for HTTP operations
- **ValueObjects** - Immutable domain objects (Mode, NIP, AccessToken, etc.)
- **Actions** - Standalone operations (encryption, QR codes, etc.)
- **HttpClient** - Faraday wrapper with logging and error handling

## Error Handling

```ruby
begin
  client.sessions.send_online(params)
rescue KSEF::ValidationError => e
  puts "Validation error: #{e.message}"
rescue KSEF::AuthenticationError => e
  puts "Auth error: #{e.message}"
rescue KSEF::NetworkError => e
  puts "Network error: #{e.message}"
rescue KSEF::ApiError => e
  puts "API error: #{e.message}"
rescue KSEF::Error => e
  puts "General error: #{e.message}"
end
```

## Best Practices

### 1. Always Save Tokens

```ruby
# After authentication, save tokens for reuse
access_token = client.access_token
refresh_token = client.refresh_token

# Save to database/cache
save_to_db(access_token.token, access_token.expires_at)
save_to_db(refresh_token.token, refresh_token.expires_at)

# Next time, reuse tokens
client = KSEF.build do
  access_token saved_access_token, expires_at: saved_expires_at
  refresh_token saved_refresh_token
end
```

### 2. Save Encryption Key

```ruby
# Generate once and save permanently
key = KSEF::ValueObjects::EncryptionKey.random
save_to_env(
  "KSEF_ENCRYPTION_KEY" => Base64.strict_encode64(key.key),
  "KSEF_ENCRYPTION_IV" => Base64.strict_encode64(key.iv)
)

# Later, load from env
client = KSEF.build do
  encryption_key(
    Base64.decode64(ENV["KSEF_ENCRYPTION_KEY"]),
    Base64.decode64(ENV["KSEF_ENCRYPTION_IV"])
  )
end
```

### 3. Use Retry for Async Operations

```ruby
# Always use retry for status checks
status = KSEF::Support::Utility.retry(backoff: 10, retry_until: 120) do
  result = client.sessions.status(reference_number)

  # Return result when done
  return result if result["status"]["code"] == 200

  # Raise error if failed
  raise KSEF::Error, result["status"]["description"] if result["status"]["code"] >= 400

  # Return nil to retry
  nil
end
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run RuboCop
bundle exec rubocop

# Console
bundle exec rake console
```

## Testing

```ruby
# spec/spec_helper.rb
require 'ksef'
require 'webmock/rspec'

RSpec.describe KSEF do
  it "builds client successfully" do
    client = KSEF.build do
      mode :test
      access_token "test_token"
    end

    expect(client).to be_a(KSEF::Resources::Client)
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a new Pull Request

## Resources

- [KSEF API Documentation](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- [KSEF Portal](https://www.podatki.gov.pl/ksef/)
- [PHP Client (reference implementation)](https://github.com/N1ebieski/ksef-php-client)

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Author

Created with ❤️ for the Ruby community

## CLI Tool

The gem includes a powerful CLI for interacting with KSEF:

```bash
# Install the gem first
gem install ksef

# Authenticate and save tokens
ksef auth --cert cert.p12 --pass mypass --nip 1234567890 --save config.json

# Send invoice
ksef send invoice.xml --config config.json --wait

# Check status
ksef status REF-123 --config config.json

# Query invoices
ksef query --from 2025-01-01 --to 2025-01-31 --config config.json

# Download invoice
ksef download KSEF-123 --config config.json --output invoice.xml

# Parse invoice XML
ksef parse invoice.xml --format info

# Generate example invoice
ksef generate --output example.xml

# Show version
ksef version
```

### CLI Configuration

You can use config file or environment variables:

**Config file (--config config.json):**
```json
{
  "mode": "test",
  "nip": "1234567890",
  "access_token": "...",
  "access_token_expires_at": "2025-01-15T12:00:00Z",
  "refresh_token": "...",
  "encryption_key": "...",
  "encryption_iv": "..."
}
```

**Environment variables:**
```bash
export KSEF_MODE=test
export KSEF_NIP=1234567890
export KSEF_ACCESS_TOKEN=...
export KSEF_REFRESH_TOKEN=...
export KSEF_ENCRYPTION_KEY=...
export KSEF_ENCRYPTION_IV=...

ksef send invoice.xml
```

## Invoice XML Parser

Parse existing KSeF XML invoices back to Ruby objects:

```ruby
# Parse XML string
xml = File.read("invoice.xml")
invoice = KSEF::InvoiceSchema::Faktura.from_xml(xml)

# Access parsed data
puts invoice.fa.p_2              # Invoice number
puts invoice.fa.p_1              # Issue date
puts invoice.fa.p_15             # Total amount
puts invoice.podmiot1.dane_identyfikacyjne.nazwa  # Seller name

# Iterate lines
invoice.fa.fa_wiersz.each do |line|
  puts "#{line.p_7}: #{line.p_9b} PLN"
end

# Convert back to XML
new_xml = invoice.to_xml

# Or to hash
hash = invoice.to_h
```

### Parse and Modify

```ruby
# Load existing invoice
invoice = KSEF::InvoiceSchema::Faktura.from_xml(File.read("invoice.xml"))

# Create modified version with updated number
modified = KSEF::InvoiceSchema::Faktura.new(
  naglowek: invoice.naglowek,
  podmiot1: invoice.podmiot1,
  podmiot2: invoice.podmiot2,
  fa: KSEF::InvoiceSchema::Fa.new(
    **invoice.fa.to_h.merge(p_2: "FV/2025/999")
  )
)

File.write("modified.xml", modified.to_xml)
```

## Roadmap

- [x] ~~Invoice XML builder/parser~~
- [x] ~~CLI tool~~
- [x] ~~Complete test coverage~~ (226 tests)
- [ ] Full XMLDSig signature implementation
- [ ] Full CSR generation
- [ ] Async parallel requests with connection pooling
- [ ] Rails integration helpers

## Support

For issues and questions:
- GitHub Issues: [github.com/yourusername/ksef-ruby/issues](https://github.com/yourusername/ksef-ruby/issues)
- Polish KSEF Forum: [4programmers.net](https://4programmers.net/Forum/Nietuzinkowe_tematy/355933)
