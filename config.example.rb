# frozen_string_literal: true

# KSeF Ruby Client - Configuration Example
# Copy this file to config.rb and fill in your values

module KSeFConfig
  # Certificate configuration
  CERT_PATH = 'path/to/your/certificate.p12'
  CERT_PASSPHRASE = 'your_certificate_password'

  # Your NIP (tax ID)
  NIP = 'your_nip_number'

  # Environment
  ENV = :test  # :test, :demo, or :production

  # Build configured client
  def self.build_client
    require_relative 'lib/ksef'

    KSEF::ClientBuilder.new
      .mode(ENV)
      .certificate_path(CERT_PATH, CERT_PASSPHRASE)
      .identifier(NIP)
      .random_encryption_key  # Auto-generate encryption key
      .build
  end
end

# Usage:
# require_relative 'config'
# client = KSeFConfig.build_client
