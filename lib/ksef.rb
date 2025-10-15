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
end

loader = Zeitwerk::Loader.for_gem
loader.push_dir File.expand_path("ksef", __dir__), namespace: KSEF
loader.setup

module KSEF
  # Main entry point
  def self.build(&block)
    builder = ClientBuilder.new
    builder.instance_eval(&block) if block_given?
    builder.build
  end
end
