# Complete KSeF API v2 Coverage

This Ruby gem now implements **100% of all endpoints** from the KSeF API v2.

## Implementation Summary

### ✅ Auth (10/10 endpoints)
- Challenge authentication
- XAdES signature authentication
- KSeF token authentication
- Status check
- Token redeem & refresh
- Session management (list, revoke)

### ✅ Certificates (7/7 endpoints)
- Enrollment (data, submit, status)
- Query & retrieve
- Revoke
- Limits check

### ✅ Security (1/1 endpoint)
- Public key certificates

### ✅ Invoices (5/5 endpoints)
- Download by KSeF number
- Query with metadata
- Exports (init, status)

### ✅ Sessions (12/12 endpoints)
- Online session (create, send, close)
- Batch session (create, send, close)
- Invoice management
- UPO retrieval (multiple methods)
- Failed invoices list
- Terminate session

### ✅ Tokens (4/4 endpoints)
- Create, list, status, revoke

### ✅ Permissions (17/17 endpoints) - **NEWLY ADDED**
- Grant permissions (persons, entities, authorizations, indirect, subunits, EU entities)
- Revoke grants (common, authorizations)
- Query grants (personal, persons, subunits, entities roles, subordinate entities, authorizations, EU entities)
- Operation status
- Attachments status

### ✅ Limits (2/2 endpoints) - **NEWLY ADDED**
- Context limits
- Subject limits

### ✅ PEPPOL (1/1 endpoint) - **NEWLY ADDED**
- Query PEPPOL data

### ✅ Testdata (10/10 endpoints)
- **Original (4):** Subject create/remove, Person create/remove
- **Newly added (6):** Permissions grant/revoke, Attachment grant/revoke, Limits (context session, subject certificate)

## Totals
- **68 endpoints implemented**
- **26 endpoints added in this update**
- **100% KSeF API v2 coverage** ✨

## Using New Modules

```ruby
client = KSEF.build do
  mode :test
  certificate_path "/path/to/cert.p12", "password"
  identifier "1234567890"
end

# Permissions
client.permissions.grant_persons(grant_data: {...})
client.permissions.query_personal_grants

# Limits
client.limits.context
client.limits.subject

# PEPPOL
client.peppol.query(query_data: {...})

# Extended Testdata
client.testdata.permissions_grant(grant_data: {...})
client.testdata.attachment_grant(attachment_data: {...})
client.testdata.limits_context_session(limits_data: {...})
```

## Documentation
- [Permissions API](./PERMISSIONS.md)
- [Limits API](./LIMITS.md)
- [PEPPOL API](./PEPPOL.md)
