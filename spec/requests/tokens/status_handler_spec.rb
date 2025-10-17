# frozen_string_literal: true

RSpec.describe KSEF::Requests::Tokens::StatusHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "active", "tokenNumber" => "TOKEN123" }) }

  describe "#call" do
    it "returns token status" do
      result = subject.call("REF123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("active")
    end

    it "calls GET tokens/{referenceNumber} endpoint" do
      expect(http_client).to receive(:get).with("tokens/REF456").and_return(double(json: {}))
      subject.call("REF456")
    end
  end
end
