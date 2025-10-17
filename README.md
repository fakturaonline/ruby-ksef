# Ruby KSeF Client 🇵🇱

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Complete Ruby client for Krajowy System e-Faktur (KSeF)** - Poland's official e-invoicing system.

## Features

- ✅ **XAdES Digital Signatures** - Complete XAdES-BES implementation
- ✅ **Certificate Authentication** - Supports qualified and self-signed certificates
- ✅ **KSeF Token Authentication** - Token-based auth support
- ✅ **Automatic Token Management** - Auto-refresh of access tokens
- ✅ **Invoice Operations** - Send, query, and download invoices
- ✅ **Session Management** - Full session lifecycle management
- ✅ **Certificate Generator** - Built-in tool for test certificates
- ✅ **100% Functional** - Production ready!

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

### Examples

- [Simple Authentication](examples/simple_authentication.rb)
- See `examples/` directory for more

## API Overview

### Authentication

```ruby
# With certificate
client = KSEF::ClientBuilder.new
  .mode(:test)
  .certificate_path('cert.p12', 'password')
  .identifier('1234567890')
  .build

# With KSeF token
client = KSEF::ClientBuilder.new
  .mode(:test)
  .ksef_token('your-token')
  .identifier('1234567890')
  .build
```

### Invoice Operations

```ruby
# Send invoice
response = client.invoices.send_invoice(invoice_xml)

# Check status
status = client.invoices.status(reference_number)

# Get invoice
invoice = client.invoices.get_invoice(ksef_reference_number)
```

### Session Management

```ruby
# List sessions
sessions = client.auth.sessions_list

# Refresh token
new_token = client.auth.refresh

# Revoke session
client.auth.revoke
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

## Status

- ✅ **Authentication**: Fully functional
- ✅ **XAdES Signing**: Complete implementation
- ✅ **Certificate Generation**: Working
- ✅ **HTTP Client**: Production ready
- ✅ **Token Management**: Automatic refresh
- ✅ **Self-signed Certs**: Supported in test environment

🟢 **Status**: Production Ready
📦 **Version**: 1.0.0

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
