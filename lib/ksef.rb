# frozen_string_literal: true

require "zeitwerk"
require "faraday"
require "nokogiri"
require "openssl"
require "multi_json"
require "base64"
require "digest"

module KSEF
  class Error < StandardError; end
  class ValidationError < Error; end
  class AuthenticationError < Error; end
  class NetworkError < Error; end
  class ApiError < Error; end

  # Define nested modules for Zeitwerk
  module ValueObjects; end
  module Resources; end
  module Requests
    module Auth; end
    module Sessions; end
    module Invoices; end
    module Certificates; end
    module Tokens; end
    module Security; end
  end
  module HttpClient; end
  module Actions; end
  module Support; end

  # Main entry point
  def self.build(&block)
    builder = ClientBuilder.new
    builder.instance_eval(&block) if block_given?
    builder.build
  end
end

loader = Zeitwerk::Loader.for_gem
loader.setup
