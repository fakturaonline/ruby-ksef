# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Sessions::UpoByKsefNumberHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:response) { instance_double(KSEF::HttpClient::Response, json: response_data) }
  let(:response_data) { { "upo" => "xml_content", "ksefNumber" => "1234567890" } }
  let(:session_ref) { "20241015-SE-ABC123" }
  let(:ksef_number) { "1234567890-20241015-ABCD-12" }

  subject { described_class.new(http_client) }

  describe "#call" do
    it "sends GET request to correct endpoint" do
      expect(http_client).to receive(:get)
        .with("sessions/#{session_ref}/invoices/ksef/#{ksef_number}/upo")
        .and_return(response)

      result = subject.call(session_ref, ksef_number)

      expect(result).to eq(response_data)
    end
  end
end
