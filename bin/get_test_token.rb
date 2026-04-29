#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper script to obtain a KSeF test token
# This script demonstrates how to authenticate and get a token from KSeF test environment
#
# Usage:
#   ruby bin/get_test_token.rb /path/to/cert.p12 password 1234567890
#
# Arguments:
#   1. Path to .p12 certificate (obtained from KSeF test environment)
#   2. Certificate password
#   3. NIP (tax identification number)

require_relative "../lib/ksef"
require "logger"

# Check arguments
if ARGV.length != 3
  puts "Usage: ruby #{$PROGRAM_NAME} /path/to/cert.p12 password NIP"
  puts
  puts "Example:"
  puts "  ruby #{$PROGRAM_NAME} ~/ksef-test-cert.p12 mypassword 7980332920"
  puts
  puts "How to get a test certificate:"
  puts "  1. Go to https://ksef-test.mf.gov.pl/ (web interface)"
  puts "  2. Register or login with test credentials"
  puts "  3. Go to Ustawienia → Certyfikaty"
  puts "  4. Generate new certificate and download .p12 file"
  exit 1
end

cert_path = ARGV[0]
cert_password = ARGV[1]
nip = ARGV[2]

# Validate certificate exists
unless File.exist?(cert_path)
  puts "❌ Certificate file not found: #{cert_path}"
  exit 1
end

puts "=" * 80
puts "KSeF Test Token Generator"
puts "=" * 80
puts "Certificate: #{cert_path}"
puts "NIP: #{nip}"
puts "Environment: TEST"
puts "=" * 80
puts

begin
  # Build client with certificate authentication
  puts "🔐 Authenticating with certificate..."

  client = KSEF.build do
    mode :test
    certificate_path cert_path, cert_password
    identifier nip
    logger Logger.new($stdout, level: Logger::INFO)
  end

  puts "✓ Authentication successful!"
  puts

  # Get access token details
  access_token = client.access_token
  puts "=" * 80
  puts "ACCESS TOKEN"
  puts "=" * 80
  puts "Token: #{access_token.token}"
  puts "Expires at: #{access_token.expires_at}"
  puts "Valid: #{access_token.valid?}"
  puts "=" * 80
  puts

  # Now create a KSeF token (long-lived token)
  puts "🔑 Creating KSeF token..."

  # List available token scopes/permissions
  # For test purposes, we'll create a token with basic permissions
  token_response = client.tokens.create(
    description: "Test token generated at #{Time.zone.now}",
    type: "standard",
    permissions: %w[InvoiceQuery InvoiceRead InvoiceWrite]
  )

  puts "✓ KSeF token created!"
  puts
  puts "=" * 80
  puts "KSEF TOKEN (use this in your tests)"
  puts "=" * 80
  puts token_response["token"]
  puts "=" * 80
  puts
  puts "Token ID: #{token_response["tokenId"]}"
  puts "Description: #{token_response["description"]}"
  puts "Permissions: #{token_response["permissions"].join(", ")}"
  puts
  puts "This token can be used for authentication without certificate:"
  puts
  puts "  client = KSEF.build do"
  puts "    mode :test"
  puts "    identifier '#{nip}'"
  puts "    ksef_token '#{token_response["token"]}'"
  puts "  end"
  puts
  puts "=" * 80
  puts "✓ Done! Copy the token above to your test configuration."
  puts "=" * 80
rescue KSEF::ApiError => e
  puts "❌ API Error: #{e.message}"
  puts
  puts "This might mean:"
  puts "  - Certificate is invalid or expired"
  puts "  - Wrong password"
  puts "  - NIP doesn't match certificate"
  puts "  - KSeF test environment is down"
  exit 1
rescue StandardError => e
  puts "❌ Error: #{e.class} - #{e.message}"
  puts
  puts e.backtrace.first(5).join("\n")
  exit 1
end
