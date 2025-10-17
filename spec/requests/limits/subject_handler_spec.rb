# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Limits::SubjectHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends GET request to limits/subject" do
      response = double(
        json: {
          "maxCertificates" => 5,
          "maxActiveTokens" => 10,
          "maxKsefTokens" => 3
        }
      )

      expect(http_client).to receive(:get).with("limits/subject").and_return(response)

      result = handler.call
      expect(result["maxCertificates"]).to eq(5)
      expect(result["maxActiveTokens"]).to eq(10)
    end
  end
end
