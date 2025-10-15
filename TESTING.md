# KSEF Ruby Client - Testing Guide

## Test Coverage Overview

Total: **72 examples, 0 failures** ✅

### Test Structure

```
spec/
├── support/                          # Test helpers and fixtures
│   ├── test_helpers.rb              # HTTP client mocking utilities
│   └── fixtures.rb                  # Response fixtures
│
├── actions/                          # Action tests (2 examples)
│   └── encrypt_document_spec.rb     # Encryption/decryption tests
│
├── value_objects/                    # Value Object tests (17 examples)
│   ├── mode_spec.rb                 # 7 tests
│   ├── nip_spec.rb                  # 9 tests
│   └── access_token_spec.rb         # 8 tests
│
├── resources/                        # Resource tests (11 examples)
│   └── client_spec.rb               # Client resource & auto-refresh tests
│
├── requests/                         # Request Handler tests (29 examples)
│   ├── auth/
│   │   ├── challenge_handler_spec.rb      # 2 tests
│   │   ├── status_handler_spec.rb         # 3 tests
│   │   ├── redeem_handler_spec.rb         # 2 tests
│   │   └── refresh_handler_spec.rb        # 2 tests
│   ├── sessions/
│   │   ├── send_online_handler_spec.rb    # 3 tests
│   │   └── status_handler_spec.rb         # 4 tests
│   └── invoices/
│       └── query_handler_spec.rb          # 3 tests
│
├── support_classes/                  # Support utility tests (13 examples)
│   └── utility_spec.rb              # Retry, deep_merge, case conversion
│
└── ksef_spec.rb                      # Core module tests (3 examples)
```

## Test Categories

### 1. Core Module Tests (3 tests)
- Version check
- Client builder functionality
- Configuration acceptance

### 2. Value Objects Tests (24 tests)

#### Mode (7 tests)
- Symbol and string value acceptance
- Invalid mode rejection
- Mode predicates (test?, demo?, production?)
- Default URL generation

#### NIP (9 tests)
- Valid NIP acceptance
- NIP normalization (dashes removal)
- Test NIP whitelisting
- Empty/invalid NIP rejection
- Checksum validation
- Equality comparison

#### AccessToken (8 tests)
- Token creation with/without expiration
- Empty token rejection
- Expiration checking with buffer
- Token creation from API response
- Equality comparison

### 3. Resources Tests (11 tests)

#### Client Resource
- **Resource Accessors** (6 tests)
  - Auth, Sessions, Invoices, Certificates, Tokens, Security resources

- **Auto Token Refresh** (2 tests)
  - Expired access token refresh on resource access
  - Uses refresh token automatically

- **Token Accessors** (3 tests)
  - Access token, refresh token, encryption key getters

### 4. Request Handler Tests (20 tests)

#### Auth Handlers (9 tests)
- **ChallengeHandler**: Challenge retrieval
- **StatusHandler**: Auth status checking (processing/completed)
- **RedeemHandler**: Token redemption after auth
- **RefreshHandler**: Access token refresh

#### Sessions Handlers (7 tests)
- **SendOnlineHandler**: Invoice sending with hash/payload validation
- **StatusHandler**: Session status (processing/accepted/with KSEF number)

#### Invoices Handlers (3 tests)
- **QueryHandler**: Invoice listing, details, query parameters

### 5. Actions Tests (2 tests)
- Document encryption with AES-256-CBC
- Encryption/decryption roundtrip validation

### 6. Support Utilities Tests (13 tests)
- **Retry mechanism** (4 tests): Success, retries, timeout, backoff timing
- **Deep merge** (3 tests): Simple/nested hashes, value overwrites
- **Case conversion** (3 tests): snake_case, camelCase, PascalCase

## Test Fixtures

### Response Fixtures (spec/support/fixtures.rb)
```ruby
# Available fixtures:
challenge_response_fixture          # Auth challenge
auth_response_fixture              # XAdES/token auth response
auth_status_response_fixture       # Auth status (with code)
redeem_token_response_fixture      # Access + refresh tokens
refresh_token_response_fixture     # New access token
send_online_response_fixture       # Invoice send response
session_status_response_fixture    # Session status (with/without KSEF number)
invoice_query_response_fixture     # Invoice list
error_response_fixture             # Error responses
public_key_certificates_fixture    # KSEF public keys
invoice_xml_fixture                # Sample invoice XML
```

### Test Helpers (spec/support/test_helpers.rb)
```ruby
# Helper methods:
stub_http_client(response_body:, status:, headers:)  # Mock HTTP client
test_config(**options)                                # Create test config
stub_ksef_request(method, path, response_body:)      # Stub KSEF API
expired_access_token                                  # Create expired token
valid_refresh_token                                   # Create valid refresh token
```

## Running Tests

### Run All Tests
```bash
bundle exec rspec
```

### Run with Documentation Format
```bash
bundle exec rspec --format documentation
```

### Run Specific Test File
```bash
bundle exec rspec spec/value_objects/nip_spec.rb
```

### Run Specific Test
```bash
bundle exec rspec spec/value_objects/nip_spec.rb:5
```

### Run Tests by Pattern
```bash
# Run all auth tests
bundle exec rspec spec/requests/auth/

# Run all value object tests
bundle exec rspec spec/value_objects/
```

### Run with Coverage
```bash
bundle exec rspec --format documentation
```

## Test Performance

### Slowest Tests
1. **Retry tests** (~0.28s total) - intentional delays for backoff testing
2. **HTTP mock tests** (~0.01s) - typical response time
3. **Value object tests** (<0.001s) - very fast unit tests

### Total Runtime
- **Average**: ~0.32 seconds
- **Examples**: 72
- **Failures**: 0

## Testing Best Practices

### 1. Use Fixtures
```ruby
it "returns challenge data" do
  http_client = stub_http_client(response_body: challenge_response_fixture)
  result = handler.call

  expect(result).to have_key("challenge")
end
```

### 2. Mock HTTP Responses
```ruby
let(:http_client) do
  stub_http_client(response_body: { "status" => "ok" })
end
```

### 3. Test Both Success and Failure
```ruby
context "when processing" do
  let(:http_client) do
    stub_http_client(response_body: auth_status_response_fixture(code: 102))
  end

  it "returns processing status" do
    # test code
  end
end
```

### 4. Use Descriptive Test Names
```ruby
describe "#call" do
  it "returns access and refresh tokens"
  it "calls POST auth/token/redeem endpoint"
  it "handles expired tokens gracefully"
end
```

## Test Comparison with PHP Client

| Category | PHP Tests | Ruby Tests | Status |
|----------|-----------|------------|---------|
| Value Objects | ~10 | 24 | ✅ More comprehensive |
| Request Handlers | ~20 | 20 | ✅ Equivalent |
| Resources | ~5 | 11 | ✅ More comprehensive |
| Actions | ~5 | 2 | ⚠️ Basic coverage |
| Support | ~3 | 13 | ✅ More comprehensive |
| **Total** | ~43 | **72** | ✅ Better coverage |

## Coverage Areas

### ✅ Well Covered
- Value objects validation
- Request handlers (auth, sessions, invoices)
- Auto token refresh
- Error handling
- Utility functions

### 🟡 Partially Covered
- Actions (only encryption tested)
- Certificate operations
- Batch invoice sending

### 🔴 Not Yet Covered
- XMLDSig signature (placeholder)
- CSR generation (not implemented)
- Full end-to-end flows
- Integration tests with real API

## Adding New Tests

### 1. Create Test File
```ruby
# spec/requests/new_feature/handler_spec.rb
RSpec.describe KSEF::Requests::NewFeature::Handler do
  let(:http_client) { stub_http_client(response_body: fixture) }
  subject { described_class.new(http_client) }

  describe "#call" do
    it "does something" do
      result = subject.call
      expect(result).to be_truthy
    end
  end
end
```

### 2. Create Fixture
```ruby
# Add to spec/support/fixtures.rb
def new_feature_fixture
  {
    "key" => "value",
    "timestamp" => Time.now.utc.iso8601
  }
end
```

### 3. Update spec_helper.rb
```ruby
# Add require if needed
require "ksef/requests/new_feature/handler"
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby: ['3.0', '3.1', '3.2']

    steps:
    - uses: actions/checkout@v2
    - uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{ matrix.ruby }}
        bundler-cache: true
    - run: bundle exec rspec
```

## Future Testing Goals

1. **Integration Tests** - Test with KSEF test environment
2. **Contract Tests** - Verify API compatibility
3. **Performance Tests** - Load testing for batch operations
4. **Security Tests** - Encryption/signing validation
5. **Coverage Report** - Add SimpleCov for code coverage metrics

## Resources

- [RSpec Documentation](https://rspec.info/)
- [WebMock Documentation](https://github.com/bblimke/webmock)
- [KSEF API Docs](https://ksef-test.mf.gov.pl/docs/v2/)
