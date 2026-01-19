# VCR Cassettes

## ⚠️ Cassettes Were Deleted (Jan 19, 2026)

All VCR cassettes were deleted due to migration to new KSeF API URLs.

## 🎯 What Needs to Be Done

### Quick Guide:

1. **Get KSeF token:**
   ```bash
   ruby bin/get_test_token.rb cert.p12 password 1234567890
   ```

2. **Set in test:**
   ```ruby
   # spec/integration/invoice_sending_spec.rb
   let(:test_ksef_token) { "YOUR_TOKEN" }
   ```

3. **Record cassettes:**
   ```bash
   bundle exec rspec spec/integration/invoice_sending_spec.rb
   ```

### Detailed Guide:
📘 **[Complete VCR Recording Guide](../../../docs/VCR_RECORDING_GUIDE.md)**

## 📦 What Cassettes Will Contain

After recording, cassettes will use **new API URLs:**
- ✅ `https://api-test.ksef.mf.gov.pl/v2`

Instead of deprecated:
- ❌ `https://ksef-test.mf.gov.pl/api/v2`

## 🔒 Security

VCR automatically filters sensitive data:
- Tokens → `<KSEF_TOKEN>`
- NIP → `<NIP>`

Before committing, always check:
```bash
grep -r "20260119-" .  # Should not find tokens
```

---

**Deleted:** January 19, 2026, 4:56 PM
**Reason:** Migration to new API URLs
**Status:** Ready to record
