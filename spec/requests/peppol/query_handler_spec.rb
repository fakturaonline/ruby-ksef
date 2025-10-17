# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Peppol::QueryHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to peppol/query with pagination" do
      query_data = {
        participant_id: "9999:PL1234567890",
        document_type: "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
      }

      response = double(
        json: {
          "results" => [
            { "id" => "1", "participantId" => "9999:PL1234567890" }
          ],
          "totalCount" => 1
        }
      )

      expect(http_client).to receive(:post).with(
        "peppol/query",
        body: query_data,
        params: { pageSize: 20, pageOffset: 0 }
      ).and_return(response)

      result = handler.call(query_data: query_data, page_size: 20, page_offset: 0)
      expect(result["results"]).to be_an(Array)
      expect(result["totalCount"]).to eq(1)
    end
  end
end
