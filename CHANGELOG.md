# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-10-15

### Added
- Initial release
- ClientBuilder with fluent API
- Value Objects (Mode, NIP, AccessToken, EncryptionKey, etc.)
- Resources for all KSEF API endpoints:
  - Auth (authentication, token management)
  - Sessions (online/batch invoice sending)
  - Invoices (query, download, status)
  - Certificates (enrollment, retrieval)
  - Tokens (list, revoke)
  - Security (public keys)
- Request handlers for HTTP operations
- Actions for encryption, decryption, and QR code generation
- Auto-authentication with certificates and KSEF tokens
- Auto-refresh of access tokens
- AES-256-CBC encryption support
- Comprehensive test suite
- Documentation and examples

### Known Limitations
- XMLDSig signature is placeholder (needs full implementation)
- CSR generation is not yet implemented
- Async parallel requests fall back to sequential
- Invoice XML builder/parser not included

[Unreleased]: https://github.com/yourusername/ksef-ruby/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/ksef-ruby/releases/tag/v0.1.0
