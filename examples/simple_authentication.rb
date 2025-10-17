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
puts "  - Send invoices: client.invoices.send_invoice(xml)"
puts "  - Check status: client.invoices.status(reference)"
puts "  - Get invoice: client.invoices.get_invoice(ksef_ref)"
puts "  - Manage sessions: client.auth.sessions_list"
