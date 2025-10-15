# KSeF API Sources

This directory contains source materials and documentation for the KSeF (Krajowy System e-Faktur) API.

## Contents

### Official Documentation
- `ksef-docs-official/` - Cloned from [CIRFMF/ksef-docs](https://github.com/CIRFMF/ksef-docs)
  - Official Polish government KSeF 2.0 integration guide
  - Version: RC5.3 (October 13, 2025)
  - Includes:
    - API specification (`open-api.json`)
    - Authentication guides (`auth/`, `uwierzytelnianie.md`)
    - Invoice management (`faktury/`, `pobieranie-faktur.md`)
    - Session guides (`sesja-interaktywna.md`, `sesja-wsadowa.md`)
    - QR code generation (`qr/`, `kody-qr.md`)
    - Certificates (`certyfikaty-KSeF.md`)
    - Tokens (`tokeny-ksef.md`)
    - Permissions (`uprawnienia.md`)
    - Limits (`limity/`)
    - Offline modes (`offline/`, `tryby-offline.md`)
    - Test data (`dane-testowe-scenariusze.md`)
    - API changelog (`api-changelog.md`)
    - Environment setup (`srodowiska.md`)

### API Specification
- `openapi.json` - OpenAPI 3.0 specification for KSeF API v2
  - Identical to `ksef-docs-official/open-api.json`
  - Used for generating client code and validation

## Updating Documentation

To update the official documentation:

```bash
cd sources/ksef-docs-official
git pull origin main
```

## References

- [KSeF Official Portal](https://www.gov.pl/web/kas/ksef)
- [CIRFMF GitHub Organization](https://github.com/CIRFMF)
- [KSeF Docs Repository](https://github.com/CIRFMF/ksef-docs)
