# KSEF Ruby Client - Architecture Documentation

## Overview

KSEF Ruby Client is a complete Ruby implementation for **Krajowy System e-Faktur** (Polish e-invoicing system). The gem provides a type-safe Ruby wrapper over KSEF REST API v2 with automatic authentication, encryption, validation, and data mapping.

Inspired by the PHP client architecture but adapted to Ruby idioms and conventions.

## Key Features

- ✅ **Type-safe** - leverages Ruby 3+ features and value objects
- ✅ **Immutable** - all objects are immutable for safety
- ✅ **Fluent API** - clean builder pattern with blocks
- ✅ **Auto-authentication** - supports certificates and KSEF tokens
- ✅ **Auto-refresh tokens** - automatic access token renewal
- ✅ **Encryption** - AES-256-CBC for invoices
- ✅ **Async batch processing** - parallel invoice sending support
- ✅ **Comprehensive** - all KSEF API v2 endpoints covered

## Architecture Layers

```
┌─────────────────────────────────────────┐
│           ClientBuilder                  │
│  (Fluent API for configuration)          │
│  KSEF.build { mode :test }              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Resources::Client                │
│  (Root resource with auto-refresh)       │
└──────┬──────────────────────────────────┘
       │
       ├──► Auth (authentication endpoints)
       ├──► Sessions (invoice operations)
       ├──► Invoices (query, download)
       ├──► Certificates (cert management)
       ├──► Tokens (token management)
       └──► Security (public keys)
              │
              ▼
       ┌──────────────────────┐
       │  Request Handlers     │
       │  (HTTP operations)    │
       └────────┬──────────────┘
                │
                ▼
       ┌──────────────────────┐
       │    HttpClient         │
       │  (Faraday wrapper)    │
       └────────┬──────────────┘
                │
                ▼
       ┌──────────────────────┐
       │      Faraday          │
       │  (HTTP library)       │
       └───────────────────────┘
```

## Directory Structure

```
lib/ksef/
├── ksef.rb                    # Main entry point, autoloading
├── version.rb                 # Gem version
├── client_builder.rb          # Fluent builder for client
├── config.rb                  # Immutable configuration object
│
├── value_objects/             # Immutable domain objects
│   ├── mode.rb               # Test/Demo/Production
│   ├── nip.rb                # Polish tax ID (with validation)
│   ├── access_token.rb       # JWT access token
│   ├── refresh_token.rb      # JWT refresh token
│   ├── ksef_token.rb         # KSEF API token
│   ├── certificate_path.rb   # Path to .p12 certificate
│   ├── encryption_key.rb     # AES-256 key + IV
│   └── encrypted_key.rb      # RSA-encrypted key
│
├── resources/                 # API endpoint wrappers
│   ├── client.rb             # Root client resource
│   ├── auth.rb               # Authentication
│   ├── sessions.rb           # Invoice sessions
│   ├── invoices.rb           # Invoice operations
│   ├── certificates.rb       # Certificate management
│   ├── tokens.rb             # Token management
│   └── security.rb           # Public keys
│
├── requests/                  # HTTP request handlers
│   ├── auth/
│   │   ├── challenge_handler.rb
│   │   ├── status_handler.rb
│   │   ├── redeem_handler.rb
│   │   ├── refresh_handler.rb
│   │   ├── revoke_handler.rb
│   │   ├── xades_signature_handler.rb
│   │   └── ksef_token_handler.rb
│   ├── sessions/
│   │   ├── send_online_handler.rb
│   │   ├── send_batch_handler.rb
│   │   ├── status_handler.rb
│   │   └── terminate_handler.rb
│   ├── invoices/
│   │   ├── download_handler.rb
│   │   ├── query_handler.rb
│   │   └── status_handler.rb
│   ├── certificates/
│   │   ├── enrollment_data_handler.rb
│   │   ├── enroll_handler.rb
│   │   ├── enrollment_status_handler.rb
│   │   └── retrieve_handler.rb
│   ├── tokens/
│   │   ├── list_handler.rb
│   │   └── revoke_handler.rb
│   └── security/
│       └── public_key_handler.rb
│
├── http_client/               # HTTP communication layer
│   ├── client.rb             # Faraday wrapper
│   └── response.rb           # Response wrapper
│
├── actions/                   # Standalone operations
│   ├── encrypt_document.rb   # AES encryption
│   ├── decrypt_document.rb   # AES decryption
│   └── generate_qr_code.rb   # QR code generation
│
└── support/                   # Utility helpers
    └── utility.rb            # Retry, deep_merge, etc.
```

## Core Components

### 1. ClientBuilder

**Purpose:** Fluent API for building and configuring KSEF client

**Usage:**
```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "passphrase"
  identifier "1234567890"
  random_encryption_key
  logger Logger.new($stdout)
end
```

**Features:**
- Fluent block-based configuration
- Auto-authentication on `build()`
- Auto-encryption key setup
- Immutable config object creation

**Build Process:**
1. Create `Config` object
2. Create `HttpClient` wrapper
3. Setup encryption key (if provided)
4. Auto-authenticate (if certificate/token provided)
5. Return configured `Resources::Client`

### 2. Config

**Purpose:** Immutable configuration container

**Key Methods:**
- `with_mode(mode)` - Returns new config with updated mode
- `with_access_token(token)` - Returns new config with token
- `with_encryption_key(key)` - Returns new config with key
- etc.

**Pattern:** Copy-on-write immutability

### 3. Resources

**Purpose:** API endpoint wrappers providing clean interface

**Example:**
```ruby
# lib/ksef/resources/auth.rb
class Auth
  def challenge
    Requests::Auth::ChallengeHandler.new(@http_client).call
  end

  def status(reference_number)
    Requests::Auth::StatusHandler.new(@http_client).call(reference_number)
  end
end
```

**Key Resources:**
- `Auth` - Authentication operations
- `Sessions` - Invoice sending (online/batch)
- `Invoices` - Query, download, status
- `Certificates` - Certificate management
- `Tokens` - Token management
- `Security` - Public key retrieval

### 4. Request Handlers

**Purpose:** Execute HTTP requests to KSEF API

**Pattern:**
```ruby
class SomeHandler
  def initialize(http_client)
    @http_client = http_client
  end

  def call(params = nil)
    response = @http_client.get("endpoint/path")
    response.json
  end
end
```

**Responsibilities:**
- Build request parameters
- Call HTTP client
- Parse response
- Return data hash

### 5. Value Objects

**Purpose:** Immutable domain objects with validation

**Example:**
```ruby
class NIP
  attr_reader :value

  def initialize(value)
    @value = normalize(value)
    validate!
  end

  private

  def validate!
    raise ValidationError unless valid_checksum?
  end
end
```

**Key Value Objects:**
- `Mode` - Operating mode (test/demo/production)
- `NIP` - Polish tax ID with checksum validation
- `AccessToken` - JWT token with expiration tracking
- `EncryptionKey` - AES-256 key + IV

### 6. HttpClient

**Purpose:** Wrapper around Faraday with logging and error handling

**Features:**
- Automatic `Authorization` header injection
- Request/response logging
- Error handling and conversion
- JSON serialization/deserialization

**Example:**
```ruby
response = http_client.post(
  "endpoint",
  body: { key: "value" },
  headers: { "Custom-Header" => "value" }
)
```

### 7. Actions

**Purpose:** Standalone operations outside API calls

**Available Actions:**
- `EncryptDocument` - AES-256-CBC encryption
- `DecryptDocument` - AES-256-CBC decryption
- `GenerateQrCode` - QR code generation for invoices

**Example:**
```ruby
encryptor = Actions::EncryptDocument.new(encryption_key)
encrypted = encryptor.call(document)
```

## Data Flow

### Typical Request Flow

```
User Code
   │
   ▼
KSEF.build { ... }
   │
   ▼
ClientBuilder
   │
   ├─► Create Config
   ├─► Create HttpClient
   ├─► Auto-authenticate (if needed)
   │   ├─► Get challenge
   │   ├─► Sign/encrypt challenge
   │   ├─► Send auth request
   │   ├─► Wait for completion (retry)
   │   └─► Redeem tokens
   │
   ▼
Resources::Client
   │
   ▼
client.sessions.send_online(params)
   │
   ▼
Resources::Sessions
   │
   ▼
Requests::Sessions::SendOnlineHandler
   │
   ▼
HttpClient::Client
   │
   ├─► Build Faraday request
   ├─► Add Authorization header
   ├─► Log request
   ├─► Send via Faraday
   ├─► Parse response
   ├─► Log response
   └─► Handle errors
   │
   ▼
Response (Hash)
   │
   ▼
User Code
```

### Auto-refresh Token Flow

```
User calls: client.sessions.send_online(...)
   │
   ▼
Resources::Client#sessions
   │
   ├─► Check if access_token.expired?
   │   │
   │   ▼ YES
   │   ├─► Check if refresh_token.valid?
   │   │   │
   │   │   ▼ YES
   │   │   ├─► Temporarily use refresh_token as access_token
   │   │   ├─► Call POST /auth/token/refresh
   │   │   ├─► Get new access_token
   │   │   └─► Update config with new token
   │   │
   │   ▼ NO (token valid)
   │   └─► Continue
   │
   ▼
Return Sessions resource with valid token
```

## Authentication Mechanisms

### 1. Certificate Authentication (.p12)

```ruby
client = KSEF.build do
  certificate_path "/path/to/cert.p12", "passphrase"
  identifier "1234567890"
end
```

**Process:**
1. Get challenge from API
2. Load PKCS#12 certificate
3. Build XAdES XML with challenge
4. Sign XML with certificate's private key
5. Send to `/auth/xades-signature`
6. Wait for status (retry every 10s)
7. Redeem tokens

**Note:** XMLDSig signature is currently a placeholder and needs full implementation.

### 2. KSEF Token Authentication

```ruby
client = KSEF.build do
  ksef_token "YOUR_KSEF_TOKEN"
  identifier "1234567890"
end
```

**Process:**
1. Get challenge and timestamp
2. Get KSEF public key certificates
3. Find `SymmetricKeyEncryption` certificate
4. Create payload: `TOKEN|TIMESTAMP`
5. Encrypt with RSA-OAEP using KSEF public key
6. Base64 encode
7. Send to `/auth/ksef-token`
8. Wait for status and redeem tokens

### 3. Existing Tokens

```ruby
client = KSEF.build do
  access_token "token", expires_at: Time.now + 3600
  refresh_token "refresh_token"
end
```

**Process:**
- Skip authentication
- Use provided tokens immediately
- Auto-refresh when access token expires (if refresh token provided)

## Encryption & Security

### AES-256-CBC Encryption

**Purpose:** Encrypt invoices before sending to KSEF

**Setup:**
```ruby
# Generate random key
key = KSEF::ValueObjects::EncryptionKey.random

# Or use existing key
key = KSEF::ValueObjects::EncryptionKey.new(
  key: Base64.decode64(ENV['KSEF_KEY']),
  iv: Base64.decode64(ENV['KSEF_IV'])
)

client = KSEF.build do
  encryption_key key.key, key.iv
end
```

**Process:**
1. On `build()`, client gets KSEF public key
2. Encrypts AES key using RSA-OAEP with KSEF public key
3. Sets `EncryptedKey` header in all invoice requests
4. KSEF uses this key to encrypt UPO and documents
5. Downloaded invoices are encrypted with same AES key
6. Decrypt using `Actions::DecryptDocument`

**Important:** Save encryption key permanently! Without it, you cannot decrypt downloaded invoices.

### RSA Encryption

**Used for:**
- Encrypting KSEF token for authentication
- Encrypting AES key for KSEF

**Algorithm:** RSA-OAEP with SHA-256

## Best Practices

### 1. Always Save Tokens

```ruby
# After authentication
access_token = client.access_token
refresh_token = client.refresh_token

# Save to database
User.update(
  ksef_access_token: access_token.token,
  ksef_access_expires_at: access_token.expires_at,
  ksef_refresh_token: refresh_token.token
)

# Next time, reuse
client = KSEF.build do
  access_token saved_token, expires_at: saved_expires_at
  refresh_token saved_refresh_token
end
```

### 2. Save Encryption Key

```ruby
# Generate once
key = KSEF::ValueObjects::EncryptionKey.random

# Save to environment or encrypted storage
ENV['KSEF_ENCRYPTION_KEY'] = Base64.strict_encode64(key.key)
ENV['KSEF_ENCRYPTION_IV'] = Base64.strict_encode64(key.iv)

# Load later
client = KSEF.build do
  encryption_key(
    Base64.decode64(ENV['KSEF_ENCRYPTION_KEY']),
    Base64.decode64(ENV['KSEF_ENCRYPTION_IV'])
  )
end
```

### 3. Use Retry for Async Operations

```ruby
status = KSEF::Support::Utility.retry(backoff: 10, retry_until: 120) do
  result = client.sessions.status(reference_number)

  # Return result when done
  return result if result["status"]["code"] == 200

  # Raise error if failed
  raise KSEF::Error, result["status"]["description"] if result["status"]["code"] >= 400

  # Return nil to retry
  nil
end
```

### 4. Error Handling

```ruby
begin
  client.sessions.send_online(params)
rescue KSEF::ValidationError => e
  # Invalid input data
rescue KSEF::AuthenticationError => e
  # Auth failed, need to re-authenticate
rescue KSEF::NetworkError => e
  # Network problem, retry
rescue KSEF::ApiError => e
  # API returned error, check e.message
rescue KSEF::Error => e
  # General KSEF error
end
```

## Testing

### RSpec Configuration

```ruby
# spec/spec_helper.rb
require 'ksef'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
```

### Example Test

```ruby
RSpec.describe KSEF::Resources::Auth do
  let(:http_client) { double('HttpClient') }
  subject { described_class.new(http_client) }

  describe '#challenge' do
    it 'returns challenge data' do
      response = double('Response', json: { 'challenge' => 'abc123' })
      expect_any_instance_of(KSEF::Requests::Auth::ChallengeHandler)
        .to receive(:call).and_return(response.json)

      result = subject.challenge
      expect(result['challenge']).to eq 'abc123'
    end
  end
end
```

### Mocking HTTP Requests

```ruby
RSpec.describe 'KSEF Integration' do
  before do
    stub_request(:get, "https://ksef-test.mf.gov.pl/api/auth/challenge")
      .to_return(
        status: 200,
        body: { challenge: 'abc123', timestamp: '2025-01-01T00:00:00Z' }.to_json
      )
  end

  it 'gets challenge successfully' do
    client = KSEF.build { mode :test; access_token "test" }
    response = client.auth.challenge
    expect(response['challenge']).to eq 'abc123'
  end
end
```

## Rails Integration

See `examples/rails_integration.rb` for complete Rails integration examples including:

- Model for storing credentials
- Background jobs for async operations
- Controllers for user actions
- Service objects for authentication

## Known Limitations

1. **XMLDSig Signature** - Currently a placeholder, needs full implementation for certificate-based auth
2. **CSR Generation** - Not yet implemented for certificate enrollment
3. **Async Parallel Requests** - Falls back to sequential processing (Faraday parallel adapter needed)
4. **Invoice XML Builder** - Not included, you need to generate XML yourself

## Future Roadmap

- [ ] Full XMLDSig signature implementation
- [ ] CSR generation for certificate enrollment
- [ ] Async parallel requests with connection pooling
- [ ] Invoice XML builder/parser
- [ ] Complete test coverage
- [ ] Rails generators for integration
- [ ] CLI tool for common operations

## Dependencies

**Runtime:**
- `faraday` - HTTP client
- `faraday-multipart` - Multipart uploads
- `nokogiri` - XML processing
- `multi_json` - JSON parsing
- `rqrcode` - QR code generation
- `dry-struct` & `dry-types` - Type safety (optional)
- `zeitwerk` - Autoloading

**Development:**
- `rspec` - Testing framework
- `webmock` - HTTP mocking
- `rubocop` - Code style
- `simplecov` - Coverage
- `pry` - Debugging

## Comparison with PHP Client

| Feature | PHP Client | Ruby Gem | Notes |
|---------|-----------|----------|-------|
| Architecture | Same layered approach | ✅ Same | Adapted to Ruby idioms |
| Immutability | Via cloning | ✅ Via frozen objects | Ruby's `freeze` |
| Fluent API | Method chaining | ✅ Block-based DSL | More Ruby-like |
| Auto-loading | Composer | ✅ Zeitwerk | Modern Ruby standard |
| DTOs | Valinor mapping | ⚠️ Manual | Could add dry-struct |
| XML Signing | Full XMLDSig | ⚠️ Placeholder | Needs implementation |
| Async | Guzzle pools | ⚠️ Sequential | Needs Faraday parallel |
| Testing | PHPUnit | ✅ RSpec | With WebMock |

## Resources

- [KSEF API Documentation](https://ksef-test.mf.gov.pl/docs/v2/index.html)
- [PHP Client (reference)](https://github.com/N1ebieski/ksef-php-client)
- [Faraday Documentation](https://lostisland.github.io/faraday/)
- [Ruby Style Guide](https://rubystyle.guide/)

## Contributing

1. Follow Ruby Style Guide
2. Write tests for new features
3. Update documentation
4. Run RuboCop before committing
5. Keep commits atomic and well-described

## License

MIT License - see LICENSE file for details
