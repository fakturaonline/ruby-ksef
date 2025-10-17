#!/usr/bin/env ruby
# frozen_string_literal: true

require 'openssl'
require 'optparse'

# Generator for self-signed test certificates compatible with KSeF test environment
class KSeFTestCertGenerator
  VALID_TYPES = %i[person organization].freeze
  VALID_KEY_TYPES = %i[ec rsa].freeze

  def initialize(type:, nip:, name: nil, output: 'test_cert.p12', passphrase: 'test123', key_type: :rsa)
    @type = type.to_sym
    @nip = nip
    @name = name || default_name
    @output = output
    @passphrase = passphrase
    @key_type = key_type.to_sym

    validate_input!
  end

  def generate
    key = generate_key
    cert = generate_certificate(key)
    pkcs12 = create_pkcs12(key, cert)

    File.write(@output, pkcs12.to_der)

    print_summary(cert)
    { certificate: cert, private_key: key, pkcs12_path: @output }
  end

  private

  def generate_key
    case @key_type
    when :rsa
      # RSA 2048-bit key (same as C# client)
      OpenSSL::PKey::RSA.new(2048)
    when :ec
      # EC P-256 (secp256r1)
      OpenSSL::PKey::EC.generate('prime256v1')
    else
      raise ArgumentError, "Unsupported key type: #{@key_type}"
    end
  end

  def generate_certificate(key)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = Random.rand(1..10_000_000)
    cert.not_before = Time.now
    cert.not_after = Time.now + (365 * 24 * 60 * 60) # 1 year

    cert.subject = build_subject
    cert.issuer = cert.subject # self-signed
    cert.public_key = key

    add_extensions(cert)
    cert.sign(key, OpenSSL::Digest.new('SHA256'))

    cert
  end

  def build_subject
    subject_attrs = case @type
                    when :person
                      build_person_subject
                    when :organization
                      build_organization_subject
                    end

    OpenSSL::X509::Name.new(subject_attrs)
  end

  def build_person_subject
    # For physical person with NIP/PESEL
    first_name, last_name = parse_person_name
    [
      ['C', 'PL', OpenSSL::ASN1::PRINTABLESTRING],
      ['GN', first_name, OpenSSL::ASN1::UTF8STRING], # givenName
      ['SN', last_name, OpenSSL::ASN1::UTF8STRING],  # surname
      ['serialNumber', "TINPL-#{@nip}", OpenSSL::ASN1::PRINTABLESTRING],
      ['CN', @name, OpenSSL::ASN1::UTF8STRING]
    ]
  end

  def build_organization_subject
    # For organization (company seal)
    [
      ['C', 'PL', OpenSSL::ASN1::PRINTABLESTRING],
      ['O', @name, OpenSSL::ASN1::UTF8STRING], # organizationName
      ['organizationIdentifier', "VATPL-#{@nip}", OpenSSL::ASN1::PRINTABLESTRING],
      ['CN', @name, OpenSSL::ASN1::UTF8STRING]
    ]
  end

  def parse_person_name
    parts = @name.split(' ', 2)
    [parts[0] || 'Jan', parts[1] || 'Kowalski']
  end

  def add_extensions(cert)
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert

    cert.add_extension(ef.create_extension('basicConstraints', 'CA:FALSE', true))
    cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash', false))

    # keyUsage: digitalSignature for Authentication certificates
    cert.add_extension(ef.create_extension('keyUsage', 'digitalSignature', true))
  end

  def create_pkcs12(key, cert)
    OpenSSL::PKCS12.create(@passphrase, @name, key, cert)
  end

  def validate_input!
    raise ArgumentError, "Invalid type: #{@type}. Use :person or :organization" unless VALID_TYPES.include?(@type)
    raise ArgumentError, "Invalid key_type: #{@key_type}. Use :rsa or :ec" unless VALID_KEY_TYPES.include?(@key_type)
    raise ArgumentError, 'NIP is required' if @nip.nil? || @nip.empty?
  end

  def default_name
    @type == :person ? 'Jan Kowalski' : 'Test Firma sp. z o.o.'
  end

  def key_type_description
    case @key_type
    when :rsa
      'RSA 2048-bit'
    when :ec
      'EC P-256 (secp256r1)'
    else
      @key_type.to_s
    end
  end

  def print_summary(cert)
    puts "\n✓ KSeF test certificate generated successfully!"
    puts "  File:       #{@output}"
    puts "  Type:       #{@type}"
    puts "  NIP:        #{@nip}"
    puts "  Subject:    #{cert.subject}"
    puts "  Issuer:     #{cert.issuer}"
    puts "  Valid from: #{cert.not_before}"
    puts "  Valid to:   #{cert.not_after}"
    puts "  Key type:   #{key_type_description}"
    puts "  Passphrase: #{@passphrase}"
    puts "\n⚠️  WARNING: Self-signed certificates are ONLY valid in TEST environment!"
    puts "\nUsage in Ruby:"
    puts "  client = KSEF::ClientBuilder.new"
    puts "    .mode(:test)"
    puts "    .certificate_path('#{@output}', '#{@passphrase}')"
    puts "    .identifier('#{@nip}')"
    puts "    .build\n\n"
  end
end

# CLI
if __FILE__ == $PROGRAM_NAME
  options = {
    type: :person,
    nip: nil,
    name: nil,
    output: 'test_cert.p12',
    passphrase: 'test123',
    key_type: :rsa
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
    opts.separator ''
    opts.separator 'Generate self-signed test certificate for KSeF test environment'
    opts.separator ''
    opts.separator 'Options:'

    opts.on('-t', '--type TYPE', KSeFTestCertGenerator::VALID_TYPES, "Certificate type (#{KSeFTestCertGenerator::VALID_TYPES.join(', ')})") do |t|
      options[:type] = t
    end

    opts.on('-n', '--nip NIP', 'NIP number (required)') do |n|
      options[:nip] = n
    end

    opts.on('--name NAME', 'Name or organization name') do |n|
      options[:name] = n
    end

    opts.on('-o', '--output FILE', 'Output PKCS12 file (default: test_cert.p12)') do |o|
      options[:output] = o
    end

    opts.on('-p', '--passphrase PASS', 'PKCS12 passphrase (default: test123)') do |p|
      options[:passphrase] = p
    end

    opts.on('-k', '--key-type TYPE', KSeFTestCertGenerator::VALID_KEY_TYPES, "Key type: rsa or ec (default: rsa)") do |k|
      options[:key_type] = k
    end

    opts.on('-h', '--help', 'Show this help') do
      puts opts
      exit
    end
  end.parse!

  if options[:nip].nil?
    puts "ERROR: NIP is required!\n\n"
    puts "Examples:"
    puts "  # Generate person certificate"
    puts "  ruby #{$PROGRAM_NAME} -t person -n 1234567890 --name 'Jan Kowalski'"
    puts ''
    puts "  # Generate organization certificate"
    puts "  ruby #{$PROGRAM_NAME} -t organization -n 9876543210 --name 'Moje Firma sp. z o.o.'"
    exit 1
  end

  begin
    generator = KSeFTestCertGenerator.new(**options)
    generator.generate
  rescue StandardError => e
    puts "ERROR: #{e.message}"
    exit 1
  end
end
