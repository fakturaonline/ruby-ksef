# Limits API

Module for retrieving limit information from the KSeF system.

## Usage

```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "password"
  identifier "1234567890"
end

# Get context limits
context_limits = client.limits.context
# => {
#   "maxSessions" => 100,
#   "maxInvoicesPerSession" => 1000,
#   ...
# }

# Get subject limits
subject_limits = client.limits.subject
# => {
#   "maxCertificates" => 5,
#   "maxActiveTokens" => 10,
#   ...
# }
```

## Available Methods

- `context` - Get context limits (sessions, invoices)
- `subject` - Get subject limits (certificates, tokens)
