# frozen_string_literal: true

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
require "pry"
require "securerandom"

# Load support files
Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

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
