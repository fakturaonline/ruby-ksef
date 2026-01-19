# Quick Start Guide 🚀

Get started with Ruby KSeF Client in 5 minutes!

**KSeF API Version**: 2.0 RC5.4 (October 15, 2025)
**Gem Version**: 1.2.0 (RC5.4 compatible)

## What's New in RC5.4

✨ **PEPPOL Support** - PEF invoice forms and PeppolId authentication
✨ **Multi-Context Auth** - Nip, InternalId, PeppolId contexts
✨ **Advanced Sorting** - sortOrder parameter in metadata queries
✨ **Export Metadata** - _metadata.json in export packages
✨ **Extended Permissions** - VatUeManage token permission

## Prerequisites

- Ruby >= 3.0
- OpenSSL >= 3.0
- Bundler

## Installation

```bash
bundle install
```

## Step 1: Generate Test Certificate

```bash
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "John Doe" \
  -o my_cert.p12 \
  -p mypassword \
  -k rsa
```

**Output:**
```
✓ KSeF test certificate generated successfully!
  File:       my_cert.p12
  Type:       person
  NIP:        1234567890
  Key type:   RSA 2048-bit
  Passphrase: mypassword
```

## Step 2: Initialize Client

```ruby
require './lib/ksef'

# Authenticate with certificate
client = KSEF::ClientBuilder.new
  .mode(:test)                              # :test, :demo, or :production
  .certificate_path('my_cert.p12', 'mypassword')
  .identifier('1234567890')                 # Your NIP
  .build

# Client is ready! 🎉
```

## Step 3: Send Invoice

```ruby
# Load FA XML
invoice_xml = File.read('invoice.xml')

# Send to KSeF
response = client.invoices.send_invoice(invoice_xml)

puts "✓ Invoice sent!"
puts "Reference: #{response['referenceNumber']}"
```

## Step 4: Check Status

```ruby
reference = response['referenceNumber']
status = client.invoices.status(reference)

if status['status']['code'] == 200
  puts "✓ Invoice processed!"
  puts "KSeF number: #{status['ksefReferenceNumber']}"
else
  puts "Processing... (#{status['status']['description']})"
end
```

## Step 5: Download Invoice

```ruby
# Download by KSeF reference number
ksef_number = '1234567890-20241017-1234567890ABCD-12'
invoice = client.invoices.get_invoice(ksef_number)

# Save
File.write('downloaded_invoice.xml', invoice)
puts "✓ Invoice downloaded!"
```

## Complete Example

```ruby
#!/usr/bin/env ruby
require './lib/ksef'

# 1. Initialize
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('my_cert.p12', 'mypassword')
  .identifier('1234567890')
  .build

# 2. Send invoice
invoice_xml = File.read('invoice.xml')
response = client.invoices.send_invoice(invoice_xml)
reference = response['referenceNumber']

puts "📤 Invoice sent: #{reference}"

# 3. Wait for processing
30.times do
  status = client.invoices.status(reference)

  if status['status']['code'] == 200
    puts "✅ Invoice processed: #{status['ksefReferenceNumber']}"
    break
  end

  print "."
  sleep 2
end

# 4. Download invoice
ksef_ref = status['ksefReferenceNumber']
invoice = client.invoices.get_invoice(ksef_ref)
File.write("downloaded_#{ksef_ref}.xml", invoice)

puts "💾 Invoice downloaded!"
```

## Authentication Options

### With Certificate

```ruby
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'password')
  .identifier('1234567890')
  .build
```

### With KSeF Token

```ruby
client = KSEF::ClientBuilder.new
  .mode(:test)
  .ksef_token('your-ksef-token')
  .identifier('1234567890')
  .build
```

## Session Management

```ruby
# Get active sessions
sessions = client.auth.sessions_list
puts "Active sessions: #{sessions['sessions'].size}"

# Refresh token
new_token = client.auth.refresh

# Revoke session
client.auth.revoke
```

## Configuration with Logging

```ruby
require 'logger'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG

client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('my_cert.p12', 'password')
  .identifier('1234567890')
  .logger(logger)
  .build
```

## Environments

```ruby
# Test (self-signed certs OK)
.mode(:test)  # https://api-test.ksef.mf.gov.pl/v2

# Demo (production-like)
.mode(:demo)  # https://api-demo.ksef.mf.gov.pl/v2

# Production (qualified certs required)
.mode(:production)  # https://api.ksef.mf.gov.pl/v2
```

## Certificate Generator - All Options

```bash
# Person (RSA)
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "John Doe" \
  -o person.p12 \
  -p password123 \
  -k rsa

# Organization (EC)
ruby bin/generate_test_cert.rb \
  -t organization \
  -n 9876543210 \
  --name "Test Company Ltd." \
  -o company.p12 \
  -p password123 \
  -k ec

# Show help
ruby bin/generate_test_cert.rb -h
```

## Troubleshooting

### Error: "Client error (401): Unauthorized"

**Problem**: Self-signed certificate not trusted for the NIP.

**Solution**:
1. For **testing**: Use test environment (already configured)
2. For **production**: Get qualified certificate from trusted CA
3. Check that NIP in certificate matches `.identifier()`

### Error: "Connection failed"

**Problem**: Cannot connect to KSeF API.

**Solution**:
```ruby
# Check mode
.mode(:test)  # not :production on test environment!

# Check network connection
require 'net/http'
Net::HTTP.get(URI('https://ksef-test.mf.gov.pl'))
```

### Error: "Invalid signature"

**Problem**: XAdES signature is invalid.

**Solution**:
- Check you're using correct certificate
- Ensure private key matches certificate
- Check PKCS#12 passphrase is correct

### Error: "File not found: cert.p12"

**Problem**: Certificate doesn't exist or wrong path.

**Solution**:
```ruby
# Use absolute path
.certificate_path('/Users/username/certs/my_cert.p12', 'pass')

# Or relative from workspace root
.certificate_path('./certs/my_cert.p12', 'pass')

# Check file exists
File.exist?('my_cert.p12')  # => true
```

## RC5.4 Advanced Features

### PEPPOL Invoices

```ruby
# Create PEF invoice
invoice = KSEF::InvoiceSchema::Faktura.new(
  naglowek: KSEF::InvoiceSchema::Naglowek.new(
    wariant_formularza: KSEF::InvoiceSchema::ValueObjects::FormCode.new("PEF"),
    system_info: 'PEPPOL Provider v1.0'
  ),
  # ... rest of invoice
)

# Authenticate as PEPPOL provider
client = KSEF.build do
  mode :test
  certificate_path "/path/to/peppol_cert.p12", "password"
  identifier "9915:123456789"  # PEPPOL ID
  context_type "PeppolId"      # Use PEPPOL context
end
```

### Advanced Metadata Queries

```ruby
# Query with sorting
results = client.invoices.query_metadata(
  filters: {
    subject_type: "subject1",
    date_range: { from: "2024-01-01", to: "2024-12-31" }
  },
  sort_order: "desc"  # RC5.4: Sort by date descending
)
```

### Export with Metadata

```ruby
# Initialize export with metadata file
response = client.invoices.exports_init(
  filters: { subject_type: "subject1", date_range: { from: "2024-01-01" } },
  include_metadata: true  # RC5.3: Include _metadata.json
)
```

### Extended Token Permissions

```ruby
# Create token with VatUeManage permission
client.tokens.create(
  permissions: ['InvoiceRead', 'VatUeManage'],  # RC5+
  description: 'Token for EU VAT management'
)
```

## Next Steps

- 📘 [Complete README](README.md)
- 📗 [Official KSeF docs](https://github.com/CIRFMF/ksef-docs)
- 🔧 [API documentation](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- ✨ [PEPPOL Guide](PEPPOL.md)
- 🔐 [Permissions Guide](PERMISSIONS.md)
- 📊 [Limits Guide](LIMITS.md)

## Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/ruby-ksef/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/ruby-ksef/discussions)

---

**🚀 Happy coding!**
