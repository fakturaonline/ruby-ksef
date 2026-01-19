# ⚠️ VCR Cassettes Were Deleted

**Date:** January 19, 2026, 4:56 PM
**Reason:** Migration to new KSeF API URLs

## What Happened

As part of the update to new KSeF API URLs, **all VCR cassettes were deleted**.

### Why?

KSeF officially moved from deprecated URLs:
- ❌ `https://ksef-test.mf.gov.pl/api/v2`

To new URLs:
- ✅ `https://api-test.ksef.mf.gov.pl/v2`

Old cassettes contained deprecated URLs, so it was better to delete them and re-record with new URLs.

## What Needs to Be Done?

### For Regular Gem Users:
👉 **NOTHING!** The gem works normally, cassettes are only for developers/tests.

### For Developers Who Want to Run Integration Tests:

**You need to record new cassettes with a valid KSeF token:**

#### Quick Steps:

```bash
# 1. Get token
ruby bin/get_test_token.rb cert.p12 password 1234567890

# 2. Set in test (spec/integration/invoice_sending_spec.rb)
let(:test_ksef_token) { "YOUR_TOKEN_HERE" }

# 3. Run test (records cassettes automatically)
bundle exec rspec spec/integration/invoice_sending_spec.rb

# 4. Verify
ls -la spec/fixtures/vcr_cassettes/invoice_sending/
# You should see: successful_fa3_highlevel.yml
```

#### Detailed Guide:

📘 **[docs/VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md)** - Complete step-by-step guide

## Documentation

The following documents were created/updated:

- 📘 [VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md) - **NEW** - How to record cassettes
- 📗 [API_URL_MIGRATION.md](docs/API_URL_MIGRATION.md) - Updated with VCR info
- 📙 [MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md) - Updated status
- 🎬 [spec/fixtures/vcr_cassettes/README.md](spec/fixtures/vcr_cassettes/README.md) - **NEW** - README in cassettes folder

## FAQ

### Q: Do I need to change anything in my code?
**A:** No! If you're just using the gem, you don't need to change anything.

### Q: My tests don't work
**A:** If you're running integration tests (`spec/integration/`), you need to record new cassettes (see guide above).

### Q: Do unit tests work?
**A:** Yes! Unit tests (`spec/` except `spec/integration/`) work normally.

### Q: When will cassettes be recorded again?
**A:** Once someone with a valid KSeF token runs the integration tests. Then they'll be committed to the repository.

### Q: Can I use old cassettes?
**A:** No, they contain deprecated URLs. It's better to record new ones.

## Status

| Component | Status |
|-----------|--------|
| Application code | ✅ Updated |
| Documentation | ✅ Updated |
| Unit tests | ✅ Working |
| VCR cassettes | ⏳ Need to record |
| Integration tests | ⏳ Require cassettes |

---

**For questions or issues, see:**
📘 [docs/VCR_RECORDING_GUIDE.md](docs/VCR_RECORDING_GUIDE.md)
