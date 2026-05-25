#!/usr/bin/env ruby
# frozen_string_literal: true

# Sign a KSeF AuthTokenRequest XML with XAdES-BES signature
#
# Usage:
#   ruby bin/sign_auth_xml.rb --input INPUT.xml --output SIGNED.xml --p12 cert.p12 --password PASSWORD
#
# Example:
#   ruby bin/sign_auth_xml.rb \
#     --input ~/Downloads/ksef_auth_request.xml \
#     --output /tmp/ksef_auth_request.signed.xml \
#     --p12 cert.p12 \
#     --password password

require_relative "../lib/ksef"
require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/sign_auth_xml.rb --input INPUT.xml --output SIGNED.xml --p12 CERT.p12 --password PASSWORD"

  opts.on("--input PATH", "Input XML file (AuthTokenRequest)") { |v| options[:input] = v }
  opts.on("--output PATH", "Output signed XML file") { |v| options[:output] = v }
  opts.on("--p12 PATH", "PKCS12 certificate (.p12) file") { |v| options[:p12] = v }
  opts.on("--password PASS", "Certificate password") { |v| options[:password] = v }
  opts.on("-h", "--help") do
    puts opts
    exit
  end
end.parse!

missing = %i[input output p12 password].reject { |k| options[k] }
unless missing.empty?
  warn "Missing required options: #{missing.map { |k| "--#{k}" }.join(", ")}"
  warn "Run with --help for usage."
  exit 1
end

unless File.exist?(options[:input])
  warn "Input file not found: #{options[:input]}"
  exit 1
end

unless File.exist?(options[:p12])
  warn "Certificate file not found: #{options[:p12]}"
  exit 1
end

xml = File.read(options[:input])
pkcs12 = OpenSSL::PKCS12.new(File.read(options[:p12]), options[:password])

signed_xml = KSEF::Actions::SignDocumentV2.new.call(
  xml,
  certificate: pkcs12.certificate,
  private_key: pkcs12.key
)

File.write(options[:output], signed_xml)
puts "Signed XML written to: #{options[:output]}"
