# Ruby KSeF Client 🇵🇱

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Complete Ruby client for Krajowy System e-Faktur (KSeF)** - Poland's official e-invoicing system.

## Features

- ✅ **100% API Coverage** - All 68 KSeF API v2 endpoints implemented
- ✅ **XAdES Digital Signatures** - Complete XAdES-BES implementation
- ✅ **Certificate Authentication** - Supports qualified and self-signed certificates
- ✅ **KSeF Token Authentication** - Token-based auth support
- ✅ **Automatic Token Management** - Auto-refresh of access tokens
- ✅ **Invoice Operations** - Send, query, and download invoices
- ✅ **Session Management** - Full session lifecycle management
- ✅ **Permissions Management** - Grant and query invoice access permissions
- ✅ **PEPPOL Support** - Query PEPPOL network data
- ✅ **Certificate Generator** - Built-in tool for test certificates
- ✅ **Production Ready** - Battle-tested and reliable

## Quick Start

### 1. Generate Certificate

```bash
ruby bin/generate_test_cert.rb \
  -t person \
  -n 1234567890 \
  --name "John Doe" \
  -k rsa \
  -o cert.p12 \
  -p password
```

### 2. Use the Client

```ruby
require './lib/ksef'

client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'password')
  .identifier('1234567890')
  .build

# Send invoice
invoice_xml = File.read('invoice.xml')
response = client.invoices.send_invoice(invoice_xml)

puts "✓ Invoice sent: #{response['referenceNumber']}"
```

## Installation

```bash
bundle install
```

## Requirements

- Ruby >= 3.0
- OpenSSL >= 3.0
- Nokogiri >= 1.15
- Faraday >= 2.0

## Documentation

### Getting Started

- 📘 **[Quick Start Guide](docs/QUICK_START.md)** - Get started in 5 minutes
- 📗 **[Complete Documentation](docs/README.md)** - Full API reference
- 📙 **[Architecture](docs/ARCHITECTURE.md)** - System architecture
- 📕 **[Invoice Schema](docs/INVOICE_SCHEMA.md)** - FA(2) XML schema guide

### Reference

- 📊 **[Status](docs/STATUS.md)** - Current project status (100% functional)
- 📋 **[Changelog](docs/CHANGELOG.md)** - Version history
- 📁 **[File Overview](docs/FILES_OVERVIEW.md)** - Project structure
- 🔐 **[Permissions API](docs/PERMISSIONS.md)** - Permissions management
- 📏 **[Limits API](docs/LIMITS.md)** - System limits
- 🌐 **[PEPPOL API](docs/PEPPOL.md)** - PEPPOL integration
- ✅ **[Complete API Coverage](docs/COMPLETE_API_COVERAGE.md)** - All 68 endpoints

### Examples

- [Simple Authentication](examples/simple_authentication.rb)
- See `examples/` directory for more

## API Overview

### Authentication

```ruby
# With certificate
client = KSEF.build do
  mode :test
  certificate_path 'cert.p12', 'password'
  identifier '1234567890'
end

# With KSeF token
client = KSEF.build do
  mode :test
  ksef_token 'your-token'
  identifier '1234567890'
end
```

### Invoice Operations

```ruby
# Send invoice
response = client.sessions.send_online(invoice_xml)

# Query invoices
invoices = client.invoices.query(
  filters: { invoiceType: "VAT" },
  page_size: 20
)

# Download invoice
invoice = client.invoices.download(ksef_number: "1234567890-20231201-ABCD-1234")
```

### Permissions Management

```ruby
# Grant permissions to a person
client.permissions.grant_persons(grant_data: {
  nip: "1234567890",
  persons: [
    { pesel: "12345678901", permissionType: "read" }
  ]
})

# Query personal grants
grants = client.permissions.query_personal_grants(
  query_data: { permission_type: "read" }
)

# Revoke a grant
client.permissions.revoke_common_grant("permission_id")
```

### Session Management

```ruby
# List active sessions
sessions = client.auth.sessions_list

# Refresh access token
new_token = client.auth.refresh

# Revoke current session
client.auth.sessions_revoke_current
```

### Limits & PEPPOL

```ruby
# Get context limits
limits = client.limits.context

# Query PEPPOL data
peppol = client.peppol.query(
  query_data: { participant_id: "9999:PL1234567890" }
)
```

## Environments

```ruby
# Test environment (self-signed certs supported)
.mode(:test)  # https://ksef-test.mf.gov.pl/api/v2

# Demo environment
.mode(:demo)  # https://ksef-demo.mf.gov.pl/api/v2

# Production environment
.mode(:production)  # https://ksef.mf.gov.pl/api/v2
```

## Certificate Generator

Generate test certificates for development:

```bash
# RSA certificate (recommended)
ruby bin/generate_test_cert.rb -t person -n 1234567890 --name "Test" -k rsa

# EC certificate
ruby bin/generate_test_cert.rb -t person -n 1234567890 --name "Test" -k ec

# Organization certificate
ruby bin/generate_test_cert.rb -t organization -n 9876543210 --name "Company Ltd" -k rsa

# Show help
ruby bin/generate_test_cert.rb -h
```

## Project Structure

```
ruby-ksef/
├── docs/                   # Documentation
│   ├── README.md           # Complete documentation
│   ├── QUICK_START.md      # Quick start guide
│   ├── ARCHITECTURE.md     # Architecture overview
│   ├── INVOICE_SCHEMA.md   # Invoice XML schema
│   ├── STATUS.md           # Project status
│   ├── CHANGELOG.md        # Version history
│   └── FILES_OVERVIEW.md   # File structure
├── bin/
│   └── generate_test_cert.rb  # Certificate generator
├── examples/
│   └── simple_authentication.rb  # Example usage
└── lib/ksef/
    ├── actions/            # XAdES signing
    ├── http_client/        # HTTP infrastructure
    ├── requests/           # API request handlers
    ├── resources/          # API resources
    └── value_objects/      # Domain objects
```

## API Coverage

- ✅ **Auth** (10/10 endpoints)
- ✅ **Certificates** (7/7 endpoints)
- ✅ **Security** (1/1 endpoint)
- ✅ **Invoices** (5/5 endpoints)
- ✅ **Sessions** (12/12 endpoints)
- ✅ **Tokens** (4/4 endpoints)
- ✅ **Permissions** (17/17 endpoints)
- ✅ **Limits** (2/2 endpoints)
- ✅ **PEPPOL** (1/1 endpoint)
- ✅ **Testdata** (10/10 endpoints)

**Total: 68/68 endpoints (100% coverage)** 🎉

🟢 **Status**: Production Ready
📦 **Version**: 1.1.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [Official KSeF Documentation](https://github.com/CIRFMF/ksef-docs)
- [KSeF C# Client](https://github.com/CIRFMF/ksef-client-csharp)
- [KSeF Java SDK](https://github.com/CIRFMF/ksef-client-java)
- [KSeF API v2](https://ksef-test.mf.gov.pl/docs/v2/index.html)

## Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/ruby-ksef/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/ruby-ksef/discussions)

---

**Made with ❤️ in Czech Republic**
Ruby 3.0+ • OpenSSL 3.0+ • Nokogiri • Faraday
