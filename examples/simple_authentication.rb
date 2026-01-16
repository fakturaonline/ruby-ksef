#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/ksef'

# Simple authentication example
puts "🔐 KSeF Authentication Example"
puts "=" * 60

# Configure client
client = KSEF::ClientBuilder.new
  .mode(:test)                              # :test, :demo, or :production
  .certificate_path('test_ruby_rsa.p12', 'test123')
  .identifier('7345606721')                 # Your NIP or PESEL
  .build

puts "✅ Authentication successful!"
puts "=" * 60
puts

# Get active sessions
sessions = client.auth.sessions_list
puts "Active sessions: #{sessions['sessions']&.size || 0}"
puts

# Client is now ready to use
puts "Client ready! You can now:"
puts "  - Send invoices: client.send_invoice_online(invoice_xml)"
puts "  - Check status: client.sessions.status(reference_number)"
puts "  - Download invoice: client.invoices.download(ksef_number)"
puts "  - Query invoices: client.invoices.query(params)"
puts "  - Manage sessions: client.auth.sessions_list"
