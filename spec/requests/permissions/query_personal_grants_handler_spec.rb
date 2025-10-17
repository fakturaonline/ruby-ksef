# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Permissions::QueryPersonalGrantsHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to permissions/query/personal/grants with pagination" do
      query_data = { permission_type: "read" }

      response = double(
        json: {
          "grants" => [
            { "id" => "1", "type" => "read" }
          ],
          "totalCount" => 1
        }
      )

      expect(http_client).to receive(:post).with(
        "permissions/query/personal/grants",
        body: query_data,
        params: { pageSize: 20, pageOffset: 0 }
      ).and_return(response)

      result = handler.call(query_data: query_data, page_size: 20, page_offset: 0)
      expect(result["grants"]).to be_an(Array)
      expect(result["totalCount"]).to eq(1)
    end
  end
end
