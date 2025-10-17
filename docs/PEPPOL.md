# PEPPOL API

Module for working with PEPPOL data in the KSeF system.

## Usage

```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "password"
  identifier "1234567890"
end

# Query PEPPOL data
results = client.peppol.query(
  query_data: {
    participant_id: "9999:PL1234567890",
    document_type: "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  },
  page_size: 20,
  page_offset: 0
)
```

## Available Methods

- `query(query_data:, page_size:, page_offset:)` - Query PEPPOL data
  - `participant_id` - PEPPOL participant ID (optional)
  - `document_type` - Document type (optional)
