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
#   "onlineSession" => {
#     "maxInvoiceSizeInMB" => 2,           # RC5.3+ (new)
#     "maxInvoiceWithAttachmentSizeInMB" => 100,  # RC5.3+ (new)
#     "maxInvoiceSizeInMib" => 2,          # deprecated (removal: 2025-10-27)
#     "maxInvoiceWithAttachmentSizeInMib" => 100  # deprecated
#   },
#   "batchSession" => { ... }
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

## Size Units (RC5.3+ Update)

⚠️ **Important Change**: KSeF API standardized size limits to MB (SI units).

| Unit | Definition | Status |
|------|-----------|--------|
| **MB** (Megabyte SI) | 1 MB = 1,000,000 bytes | ✅ **New standard (RC5.3+)** |
| **MiB** (Mebibyte) | 1 MiB = 1,048,576 bytes | ⚠️ **Deprecated (removal: 2025-10-27)** |

**Migration Guide:**
- Use `maxInvoiceSizeInMB` instead of `maxInvoiceSizeInMib`
- Use `maxInvoiceWithAttachmentSizeInMB` instead of `maxInvoiceWithAttachmentSizeInMib`
- Both fields are currently returned for backward compatibility
- Update your code before October 27, 2025

## Test Environment Limits

You can set custom limits in test environment:

```ruby
# Set context session limits
client.testdata.limits_context_session(
  limits_data: {
    onlineSession: {
      maxInvoiceSizeInMB: 5,  # Use MB (not MiB)
      maxInvoiceWithAttachmentSizeInMB: 150
    }
  }
)
```
