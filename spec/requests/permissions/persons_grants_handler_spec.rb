# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Permissions::PersonsGrantsHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to permissions/persons/grants" do
      grant_data = {
        nip: "1234567890",
        persons: [
          { pesel: "12345678901", permissionType: "read" }
        ]
      }

      response = double(json: { "referenceNumber" => "ref_123" })

      expect(http_client).to receive(:post).with("permissions/persons/grants", body: grant_data).and_return(response)

      result = handler.call(grant_data: grant_data)
      expect(result).to eq({ "referenceNumber" => "ref_123" })
    end
  end
end
