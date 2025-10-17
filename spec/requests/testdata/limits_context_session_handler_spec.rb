# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Testdata::LimitsContextSessionHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to testdata/limits/context/session" do
      limits_data = {
        max_sessions: 50,
        max_invoices_per_session: 500
      }

      response = double(json: { "status" => "applied" })

      expect(http_client).to receive(:post).with(
        "testdata/limits/context/session",
        body: limits_data
      ).and_return(response)

      result = handler.call(limits_data: limits_data)
      expect(result).to eq({ "status" => "applied" })
    end
  end
end
