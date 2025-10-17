# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Testdata::PermissionsGrantHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to testdata/permissions" do
      grant_data = {
        nip: "1234567890",
        permissions: [
          { type: "read", grantee: "12345678901" }
        ]
      }

      response = double(json: { "status" => "granted" })

      expect(http_client).to receive(:post).with("testdata/permissions", body: grant_data).and_return(response)

      result = handler.call(grant_data: grant_data)
      expect(result).to eq({ "status" => "granted" })
    end
  end
end
