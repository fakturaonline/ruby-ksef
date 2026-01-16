# PEPPOL API

Module for working with PEPPOL data in the KSeF system.

**KSeF API Version**: RC5+ with full PEPPOL support

## Overview

KSeF API 2.0 RC5+ introduces comprehensive PEPPOL network integration:

- **PEPPOL Service Providers** - Automatic registration on first authentication
- **PEF Invoice Forms** - New invoice formats: `PEF (3)` and `PEF_KOR (3)`
- **PeppolId Context** - New authentication context type for PEPPOL providers
- **Provider Query** - List registered PEPPOL service providers
- **Special Permissions** - `PefInvoiceWrite` permission required for PEF invoices

## PEPPOL Authentication

PEPPOL service providers can authenticate using `PeppolId` context type:

```ruby
# Authenticate as PEPPOL provider (requires PEPPOL certificate)
client = KSEF.build do
  mode :test
  certificate_path "/path/to/peppol_cert.p12", "password"
  identifier "9915:123456789"  # PEPPOL participant ID
  context_type "PeppolId"      # Use PEPPOL context
end
```

**Note**: First authentication with PEPPOL certificate automatically registers the provider in KSeF.

## Querying PEPPOL Data

## Usage

```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "password"
  identifier "1234567890"
end

# Query PEPPOL data
results = client.peppol.query(
  query_data: {
    participant_id: "9999:PL1234567890",
    document_type: "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  },
  page_size: 20,
  page_offset: 0
)
```

## Available Methods

- `query(query_data:, page_size:, page_offset:)` - Query registered PEPPOL service providers
  - `participant_id` - PEPPOL participant ID (optional)
  - `document_type` - Document type (optional)

## PEF Invoices

PEPPOL invoices use special form codes introduced in RC5.3:

```ruby
# Create PEF invoice
invoice = KSEF::InvoiceSchema::Faktura.new(
  naglowek: KSEF::InvoiceSchema::Naglowek.new(
    wariant_formularza: KSEF::InvoiceSchema::ValueObjects::FormCode.new("PEF"),
    system_info: 'PEPPOL Provider v1.0'
  ),
  # ... rest of invoice
)

# Send PEF invoice (requires PefInvoiceWrite permission)
response = client.sessions.send_invoice(invoice.to_xml)
```

**Form Codes:**
- `PEF (3)` - PEPPOL Electronic Format invoice
- `PEF_KOR (3)` - PEPPOL Electronic Format correction invoice

**Required Permissions:**
- Session opening/closing: `PefInvoiceWrite`
- Invoice sending: `PefInvoiceWrite`

## Context Types

KSeF supports three authentication context types (RC5+):

| Context Type | Description | Example |
|--------------|-------------|---------|
| `Nip` | Polish tax ID | `"1234567890"` |
| `InternalId` | Internal identifier | `"INT-12345"` |
| `PeppolId` | PEPPOL participant ID | `"9915:123456789"` |

## Reference

- [Official PEPPOL Documentation](https://peppol.org/)
- [KSeF PEPPOL Integration](../sources/ksef-docs-official/README.md)
