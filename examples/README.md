# KSeF Examples

This directory contains working examples demonstrating various features of the Ruby KSeF client.

## Executable Examples

These examples can be run directly from the command line:

### 1. Simple Authentication
```bash
ruby examples/simple_authentication.rb
```

**Purpose:** Demonstrates basic client setup and authentication with certificate.

**Shows:**
- Client configuration
- Certificate authentication
- Session listing
- Available API methods

**Requirements:**
- Valid test certificate (`test_ruby_rsa.p12`)
- Valid NIP/PESEL identifier

---

### 2. Invoice Example
```bash
ruby examples/invoice_example.rb
```

**Purpose:** Creates a basic FA(2) invoice and generates XML.

**Shows:**
- Creating seller (Podmiot1) and buyer (Podmiot2)
- Creating invoice lines (FaWiersz)
- Building complete invoice (Faktura)
- Generating valid KSeF XML

**Output:** Complete FA(2) XML invoice

---

### 3. FakturaOnline Mapping
```bash
ruby examples/fakturaonline_mapping.rb
```

**Purpose:** Comprehensive mapping from FakturaOnline data structure to KSeF FA(2) XML.

**Shows:**
- Complete field mapping
- Contact information (email, phone)
- Bank accounts (IBAN, SWIFT)
- Payment terms and conditions
- DUZP (tax point date)
- Footer with annotations
- All DTOs in action

**Output:** Complete FA(2) XML with all fields mapped

---

### 4. Parser Demo
```bash
ruby examples/parser_demo.rb
```

**Purpose:** Demonstrates XML serialization and parsing capabilities.

**Shows:**
- Creating invoice objects
- Serializing to XML (`to_xml`)
- Parsing from XML (`from_xml`)
- Round-trip conversion
- Data verification

**Output:** Verification of XML parsing accuracy

---

## Reference Examples

These are templates and patterns, not meant to be executed standalone:

### 5. Rails Integration
```bash
# View only - requires Rails environment
cat examples/rails_integration.rb
```

**Purpose:** Reference template for integrating KSeF into Ruby on Rails applications.

**Shows:**
- Model integration (`KsefCredential`, `Invoice`)
- Background job processing (`KsefSendInvoiceJob`, `KsefCheckStatusJob`)
- Credential management
- Service objects (`KsefAuthService`)
- Controller actions
- Error handling patterns

**Note:** This is a reference/template file showing integration patterns. It requires a Rails application environment to run.

---

## Quick Start

1. **Generate a test certificate:**
   ```bash
   ruby bin/generate_test_cert.rb -t person -n 1234567890 --name "Test" -k rsa -o test_cert.p12 -p test123
   ```

2. **Run simple authentication:**
   ```bash
   ruby examples/simple_authentication.rb
   ```

3. **Generate an invoice:**
   ```bash
   ruby examples/invoice_example.rb > invoice.xml
   ```

4. **Explore other examples:**
   ```bash
   ruby examples/fakturaonline_mapping.rb
   ruby examples/parser_demo.rb
   ```

## Requirements

All examples require:
- Ruby >= 3.0
- Bundled gems (`bundle install`)
- For authentication examples: Valid certificate and NIP

## Testing

All executable examples have been tested and verified working:

```bash
# Test all examples
for file in simple_authentication.rb invoice_example.rb fakturaonline_mapping.rb parser_demo.rb; do
  echo "Testing $file..."
  ruby examples/$file > /dev/null && echo "✓ PASS" || echo "✗ FAIL"
done
```

## Status

✅ **4/4 executable examples working (100%)**
📘 **1/1 reference example documented**

Last updated: October 17, 2025
