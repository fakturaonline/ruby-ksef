# Permissions API

Module for managing permissions in the KSeF system. Enables delegation of invoice access between persons and entities.

## Usage

```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "password"
  identifier "1234567890"
end

# Grant permissions to persons
response = client.permissions.grant_persons(grant_data: {
  nip: "1234567890",
  persons: [
    { pesel: "12345678901", permissionType: "read" }
  ]
})

# Grant permissions to entities
response = client.permissions.grant_entities(grant_data: {
  nip: "1234567890",
  entities: [
    { nip: "9876543210", permissionType: "write" }
  ]
})

# Query personal grants
grants = client.permissions.query_personal_grants(
  query_data: { permission_type: "read" },
  page_size: 20
)

# Revoke a grant
client.permissions.revoke_common_grant("permission_id_123")

# Check operation status
status = client.permissions.operation_status("reference_number")
```

## Available Methods

### Granting Permissions
- `grant_persons(grant_data:)` - Grant permissions to persons
- `grant_entities(grant_data:)` - Grant permissions to entities
- `grant_authorizations(grant_data:)` - Grant authorizations
- `grant_indirect(grant_data:)` - Grant indirect permissions
- `grant_subunits(grant_data:)` - Grant permissions to subunits
- `grant_eu_entities_administration(grant_data:)` - Grant administration permissions to EU entities
- `grant_eu_entities(grant_data:)` - Grant permissions to EU entities

### Revoking Permissions
- `revoke_common_grant(permission_id)` - Revoke common grant
- `revoke_authorization_grant(permission_id)` - Revoke authorization grant

### Querying Permissions
- `query_personal_grants(query_data:, page_size:, page_offset:)` - Query personal grants
- `query_persons_grants(query_data:, page_size:, page_offset:)` - Query persons grants
- `query_subunits_grants(query_data:, page_size:, page_offset:)` - Query subunits grants
- `query_entities_roles(query_data:, page_size:, page_offset:)` - Query entities roles
- `query_subordinate_entities_roles(query_data:, page_size:, page_offset:)` - Query subordinate entities roles
- `query_authorizations_grants(query_data:, page_size:, page_offset:)` - Query authorizations grants
- `query_eu_entities_grants(query_data:, page_size:, page_offset:)` - Query EU entities grants

### Status & Attachments
- `operation_status(reference_number)` - Check operation status
- `attachments_status(filters:)` - Check attachments status
