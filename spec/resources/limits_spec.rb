# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Limits do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:limits) { described_class.new(http_client) }

  describe "#context" do
    it "delegates to ContextHandler" do
      handler = instance_double(KSEF::Requests::Limits::ContextHandler)
      allow(KSEF::Requests::Limits::ContextHandler).to receive(:new).with(http_client).and_return(handler)

      expected_response = {
        "maxSessions" => 100,
        "maxInvoicesPerSession" => 1000
      }

      expect(handler).to receive(:call).and_return(expected_response)

      result = limits.context
      expect(result).to eq(expected_response)
    end
  end

  describe "#subject" do
    it "delegates to SubjectHandler" do
      handler = instance_double(KSEF::Requests::Limits::SubjectHandler)
      allow(KSEF::Requests::Limits::SubjectHandler).to receive(:new).with(http_client).and_return(handler)

      expected_response = {
        "maxCertificates" => 5,
        "maxActiveTokens" => 10
      }

      expect(handler).to receive(:call).and_return(expected_response)

      result = limits.subject
      expect(result).to eq(expected_response)
    end
  end
end
