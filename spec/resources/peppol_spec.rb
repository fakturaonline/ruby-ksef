# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Peppol do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:peppol) { described_class.new(http_client) }

  describe "#query" do
    it "delegates to QueryHandler" do
      handler = instance_double(KSEF::Requests::Peppol::QueryHandler)
      allow(KSEF::Requests::Peppol::QueryHandler).to receive(:new).with(http_client).and_return(handler)

      query_data = { participant_id: "9999:PL1234567890" }
      expected_response = {
        "results" => [],
        "totalCount" => 0
      }

      expect(handler).to receive(:call).with(
        query_data: query_data,
        page_size: 20,
        page_offset: 0
      ).and_return(expected_response)

      result = peppol.query(query_data: query_data, page_size: 20, page_offset: 0)
      expect(result).to eq(expected_response)
    end
  end
end
