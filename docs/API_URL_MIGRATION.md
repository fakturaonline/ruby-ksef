# API URL Migration - January 2026

## Overview of Changes

In January 2026, KSeF officially moved to new API addresses. Old addresses are marked as **deprecated**.

## New vs. Old URLs

| Environment | New Address (active) | Old Address (deprecated) |
|-----------|----------------------|---------------------------|
| **Test** | `https://api-test.ksef.mf.gov.pl/v2` | `https://ksef-test.mf.gov.pl/api/v2` |
| **Demo** | `https://api-demo.ksef.mf.gov.pl/v2` | `https://ksef-demo.mf.gov.pl/api/v2` |
| **Production** | `https://api.ksef.mf.gov.pl/v2` | `https://ksef.mf.gov.pl/api/v2` |

### Web Interface (unchanged)

Web interface remains at original addresses:
- Test: `https://ksef-test.mf.gov.pl` (without `/api`)
- Demo: `https://ksef-demo.mf.gov.pl`
- Production: `https://ksef.mf.gov.pl`

## What Was Updated

### 1. Application Code
✅ `lib/ksef/value_objects/mode.rb` - URL constants (already had correct values)

### 2. Documentation
✅ `README.md` - Updated environment examples
✅ `docs/QUICK_START.md` - Updated URLs in examples
✅ `docs/TESTING.md` - Updated API links
✅ `docs/ARCHITECTURE.md` - Updated mocking examples
✅ `docs/README.md` - Added link to new API
✅ `docs/CHANGELOG.md` - Added migration record
✅ `sources/ksef-docs-official/srodowiska.md` - Added note about new URLs

### 3. Helper Scripts
✅ `bin/get_test_token.rb` - Updated comment with web interface note

### 4. Tests
✅ `spec/value_objects/mode_spec.rb` - Updated expected URLs in tests
✅ `spec/integration/README.md` - Updated API links

### 5. What Was DELETED
🔄 **VCR cassettes** - All cassettes deleted (Jan 19, 2026) due to migration to new URLs
   - Need to re-record with valid token
   - See [VCR Recording Guide](VCR_RECORDING_GUIDE.md)

### 6. What Was NOT Changed
❌ **Web links** - Links to web interface remain at original URLs

## Impact on Users

### ✅ No Code Changes
Gem users **don't need to change their code**. The gem automatically uses correct URLs:

```ruby
# Automatically uses https://api-test.ksef.mf.gov.pl/v2
client = KSEF.build do
  mode :test
  certificate_path 'cert.p12', 'password'
  identifier '1234567890'
end
```

### ✅ Automatic Migration
On client initialization, the correct URL is used based on `mode`:
- `:test` → `https://api-test.ksef.mf.gov.pl/v2`
- `:demo` → `https://api-demo.ksef.mf.gov.pl/v2`
- `:production` → `https://api.ksef.mf.gov.pl/v2`

### ⚠️ Custom URL
If someone explicitly set a custom URL, they should check:

```ruby
# If you have this:
client = KSEF.build do
  mode :test
  api_url 'https://ksef-test.mf.gov.pl/api/v2'  # DEPRECATED!
end

# Change to:
client = KSEF.build do
  mode :test
  api_url 'https://api-test.ksef.mf.gov.pl/v2'  # NEW
end

# Or even better - use default URL:
client = KSEF.build do
  mode :test  # Automatically uses correct URL
end
```

## Testing Migration

### Running Tests
```bash
# Unit tests (including mode_spec.rb)
bundle exec rspec spec/value_objects/mode_spec.rb

# All tests
bundle exec rspec
```

### Manual Verification
```ruby
require './lib/ksef'

# Test URL
mode = KSEF::ValueObjects::Mode.new(:test)
puts mode.default_url
# => "https://api-test.ksef.mf.gov.pl/v2"

# Demo URL
mode = KSEF::ValueObjects::Mode.new(:demo)
puts mode.default_url
# => "https://api-demo.ksef.mf.gov.pl/v2"

# Production URL
mode = KSEF::ValueObjects::Mode.new(:production)
puts mode.default_url
# => "https://api.ksef.mf.gov.pl/v2"
```

## Timeline

- **January 2026** - KSeF officially moved to new URLs
- **Jan 19, 2026 2:00 PM** - Ruby KSeF gem updated
- **Jan 19, 2026 4:56 PM** - VCR cassettes deleted (need to re-record)
- **TBD** - Old URLs will probably work for a while longer (backward compatibility)

## ⚠️ Action Required: Recording New VCR Cassettes

VCR cassettes were **deleted** due to migration to new URLs.

### What needs to be done:

1. **Get valid KSeF token:**
   ```bash
   ruby bin/get_test_token.rb cert.p12 password 1234567890
   ```
   Or via web interface: https://ksef-test.mf.gov.pl/ → Ustawienia → Tokeny

2. **Set token in test:**
   ```ruby
   # spec/integration/invoice_sending_spec.rb
   let(:test_ksef_token) { "YOUR_VALID_TOKEN" }
   ```

3. **Record new cassettes:**
   ```bash
   bundle exec rspec spec/integration/invoice_sending_spec.rb
   ```

4. **Verify:**
   ```bash
   # Check that it uses new URLs
   head -20 spec/fixtures/vcr_cassettes/invoice_sending/successful_fa3_highlevel.yml
   # Should be: https://api-test.ksef.mf.gov.pl/v2
   ```

### Detailed Guide:
📘 [VCR Recording Guide](VCR_RECORDING_GUIDE.md) - Complete step-by-step guide

## Links

- 📘 [Official KSeF Documentation](https://github.com/CIRFMF/ksef-docs)
- 📗 [API Documentation](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- 📙 [Test Environment - Web](https://ksef-test.mf.gov.pl)
- 🔧 [New API Server - Test](https://api-test.ksef.mf.gov.pl/v2)
- 🎬 [VCR Recording Guide](VCR_RECORDING_GUIDE.md)

## Changelog

Complete list of changes see [CHANGELOG.md](CHANGELOG.md#unreleased---2026-01-19)

---

**Completed:** January 19, 2026
**Status:** ⚠️ Need to record VCR cassettes
**Breaking changes:** ❌ None (for regular usage)
