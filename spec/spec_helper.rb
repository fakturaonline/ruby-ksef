# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/bin/"
    add_filter "/exe/"
    add_filter "/vendor/"

    add_group "Actions", "lib/ksef/actions"
    add_group "Resources", "lib/ksef/resources"
    add_group "Requests", "lib/ksef/requests"
    add_group "Factories", "lib/ksef/factories"
    add_group "ValueObjects", "lib/ksef/value_objects"
    add_group "InvoiceSchema", "lib/ksef/invoice_schema"
    add_group "Validator", "lib/ksef/validator"
    add_group "Support", "lib/ksef/support"
    add_group "Core", "lib/ksef"
  end
end

require "ksef"

# Manually require test dependencies
require "ksef/client_builder"
require "ksef/config"
require "ksef/http_client/client"
require "ksef/http_client/response"
require "ksef/resources/client"
require "ksef/resources/auth"
require "ksef/resources/sessions"
require "ksef/resources/invoices"
require "ksef/resources/certificates"
require "ksef/resources/tokens"
require "ksef/resources/security"
require "ksef/value_objects/mode"
require "ksef/value_objects/nip"
require "ksef/value_objects/access_token"
require "ksef/value_objects/refresh_token"
require "ksef/value_objects/encryption_key"
require "ksef/actions/encrypt_document"
require "ksef/actions/decrypt_document"
require "ksef/support/utility"
require "ksef/requests/auth/challenge_handler"
require "ksef/requests/auth/status_handler"
require "ksef/requests/auth/redeem_handler"
require "ksef/requests/auth/refresh_handler"
require "ksef/requests/sessions/send_online_handler"
require "ksef/requests/sessions/status_handler"
require "ksef/requests/invoices/query_handler"

require "webmock/rspec"
require "vcr"
require "pry"
require "securerandom"

# Load support files
Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

# Configure VCR
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  
  # Filter sensitive data
  config.filter_sensitive_data("<KSEF_TOKEN>") { |interaction|
    if interaction.request.headers["Sessiontoken"]
      interaction.request.headers["Sessiontoken"].first
    end
  }
  
  config.filter_sensitive_data("<KSEF_TOKEN>") do |interaction|
    # Filter token from request body
    if interaction.request.body.include?("ksefToken")
      interaction.request.body.match(/"ksefToken":\s*"([^"]+)"/)[1] rescue nil
    end
  end
  
  config.filter_sensitive_data("<NIP>") do |interaction|
    # Filter NIP from URLs
    if interaction.request.uri.include?("7980332920")
      "7980332920"
    end
  end
  
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  # Disable external HTTP requests
  WebMock.disable_net_connect!(allow_localhost: true)
end
