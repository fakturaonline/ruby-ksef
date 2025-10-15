# frozen_string_literal: true

require_relative "lib/ksef/version"

Gem::Specification.new do |spec|
  spec.name = "ksef"
  spec.version = KSEF::VERSION
  spec.authors = ["Tonda Pleskac"]
  spec.email = ["tonda@example.com"]

  spec.summary = "Ruby client for Polish KSEF (Krajowy System e-Faktur) API"
  spec.description = "Complete Ruby implementation for KSEF e-invoicing system with support for authentication, encryption, batch processing, and more."
  spec.homepage = "https://github.com/yourusername/ksef-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # HTTP client
  spec.add_dependency "faraday", "~> 2.0"

  # XML processing
  spec.add_dependency "nokogiri", "~> 1.15"

  # JSON
  spec.add_dependency "multi_json", "~> 1.15"

  # Crypto
  spec.add_dependency "openssl", ">= 3.0"

  # QR codes
  spec.add_dependency "rqrcode", "~> 2.0"

  # CLI
  spec.add_dependency "thor", "~> 1.3"

  # Utilities
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Development dependencies
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.56"
  spec.add_development_dependency "rubocop-rspec", "~> 2.24"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "vcr", "~> 6.2"
  spec.add_development_dependency "webmock", "~> 3.19"
end
