# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Limits::ContextHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends GET request to limits/context" do
      response = double(
        json: {
          "maxSessions" => 100,
          "maxInvoicesPerSession" => 1000,
          "maxInvoicesPerDay" => 10000
        }
      )

      expect(http_client).to receive(:get).with("limits/context").and_return(response)

      result = handler.call
      expect(result["maxSessions"]).to eq(100)
      expect(result["maxInvoicesPerSession"]).to eq(1000)
    end
  end
end
