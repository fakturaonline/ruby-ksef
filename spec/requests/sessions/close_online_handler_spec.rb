# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Sessions::CloseOnlineHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:response) { instance_double(KSEF::HttpClient::Response, json: response_data) }
  let(:response_data) { { "timestamp" => "2024-10-15T12:00:00Z", "referenceNumber" => session_ref } }
  let(:session_ref) { "20241015-SE-ABC123" }

  describe "#call" do
    it "sends POST request to close online session" do
      expect(http_client).to receive(:post)
        .with("sessions/online/#{session_ref}/close")
        .and_return(response)

      result = subject.call(session_ref)

      expect(result).to eq(response_data)
    end
  end
end
