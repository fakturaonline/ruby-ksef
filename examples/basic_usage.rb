# frozen_string_literal: true

require "ksef"
require "logger"

# Example 1: Basic setup with certificate authentication
def example_certificate_auth
  puts "\n=== Certificate Authentication Example ==="

  client = KSEF.build do
    mode :test
    certificate_path "/path/to/cert.p12", "passphrase"
    identifier "1234567890"
    random_encryption_key
    logger Logger.new($stdout, level: Logger::INFO)
  end

  puts "✅ Client authenticated successfully!"
  puts "Access Token: #{client.access_token.token[0..20]}..."
  puts "Expires at: #{client.access_token.expires_at}"
end

# Example 2: Using existing tokens
def example_existing_tokens
  puts "\n=== Using Existing Tokens Example ==="

  # Simulate loading tokens from database/cache
  saved_access_token = "your_access_token"
  saved_access_expires = Time.now + 3600
  saved_refresh_token = "your_refresh_token"

  client = KSEF.build do
    mode :production
    access_token saved_access_token, expires_at: saved_access_expires
    refresh_token saved_refresh_token
    identifier "1234567890"
  end

  puts "✅ Client ready with existing tokens!"
end

# Example 3: Send online invoice
def example_send_invoice(client)
  puts "\n=== Send Invoice Example ==="

  invoice_xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <Faktura xmlns="http://crd.gov.pl/wzor/2023/06/29/12648/">
      <!-- Invoice content here -->
    </Faktura>
  XML

  # Calculate hash
  invoice_hash = Digest::SHA256.base64digest(invoice_xml)

  # Send invoice
  response = client.sessions.send_online(
    invoice_hash: invoice_hash,
    invoice_payload: Base64.strict_encode64(invoice_xml)
  )

  reference_number = response["referenceNumber"]
  puts "Invoice sent! Reference: #{reference_number}"

  # Wait for processing
  status = KSEF::Support::Utility.retry(backoff: 10, retry_until: 120) do
    result = client.sessions.status(reference_number)
    result["status"]["code"] == 200 ? result : nil
  end

  puts "✅ Invoice processed!"
  puts "KSEF Number: #{status['ksefNumber']}"
end

# Example 4: Query invoices
def example_query_invoices(client)
  puts "\n=== Query Invoices Example ==="

  results = client.invoices.query(
    from_date: "2025-01-01",
    to_date: "2025-01-31",
    invoice_type: "sent"
  )

  puts "Found #{results['invoices'].length} invoices:"
  results["invoices"].first(5).each do |invoice|
    puts "  - #{invoice['ksefNumber']}: #{invoice['amount']} PLN"
  end
end

# Example 5: Download and decrypt invoice
def example_download_invoice(client, ksef_number)
  puts "\n=== Download Invoice Example ==="

  # Download (encrypted)
  encrypted = client.invoices.download(ksef_number)
  puts "Downloaded #{encrypted.bytesize} bytes (encrypted)"

  # Decrypt
  decryptor = KSEF::Actions::DecryptDocument.new(client.encryption_key)
  invoice_xml = decryptor.call(encrypted)

  puts "✅ Invoice decrypted!"
  puts invoice_xml[0..200] + "..."
end

# Example 6: Generate QR code
def example_qr_code
  puts "\n=== QR Code Generation Example ==="

  generator = KSEF::Actions::GenerateQrCode.new(
    nip: "1234567890",
    invoice_date: Date.today,
    ksef_number: "1234567890-20250115-ABCDEF123456-78"
  )

  qr_code = generator.call

  File.write("invoice_qr.svg", qr_code[:svg])
  puts "✅ QR code saved to invoice_qr.svg"
  puts "Data: #{qr_code[:data]}"
end

# Example 7: Encryption/Decryption
def example_encryption
  puts "\n=== Encryption Example ==="

  # Generate key
  key = KSEF::ValueObjects::EncryptionKey.random
  puts "Generated encryption key"
  puts "Key: #{Base64.strict_encode64(key.key)}"
  puts "IV:  #{Base64.strict_encode64(key.iv)}"

  # Encrypt
  document = "Secret invoice content"
  encryptor = KSEF::Actions::EncryptDocument.new(key)
  encrypted = encryptor.call(document)
  puts "Encrypted: #{encrypted.bytesize} bytes"

  # Decrypt
  decryptor = KSEF::Actions::DecryptDocument.new(key)
  decrypted = decryptor.call(encrypted)
  puts "Decrypted: #{decrypted}"
end

# Example 8: Error handling
def example_error_handling
  puts "\n=== Error Handling Example ==="

  begin
    nip = KSEF::ValueObjects::Nip.new("invalid")
  rescue KSEF::ValidationError => e
    puts "❌ Validation Error: #{e.message}"
  end

  begin
    # Simulate API error
    raise KSEF::ApiError, "Invoice not found (404)"
  rescue KSEF::ApiError => e
    puts "❌ API Error: #{e.message}"
  end

  puts "✅ Errors handled gracefully"
end

# Main
if __FILE__ == $PROGRAM_NAME
  puts "KSEF Ruby Client - Usage Examples"
  puts "=" * 50

  # Run examples
  example_encryption
  example_qr_code
  example_error_handling

  puts "\n✅ All examples completed!"
  puts "\nNote: Some examples are commented out as they require"
  puts "valid credentials and connection to KSEF API."
end
