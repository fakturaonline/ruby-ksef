# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "upoData" => "base64data" }) }

  describe "#call" do
    it "returns UPO by UPO reference" do
      result = subject.call("SESSION-123", "UPO-REF-123")

      expect(result).to be_a(Hash)
      expect(result["upoData"]).to eq("base64data")
    end

    it "calls GET sessions/{sessionReference}/upo/{upoReference} endpoint" do
      expect(http_client).to receive(:get).with("sessions/SESSION-456/upo/UPO-REF-456").and_return(double(json: {}))
      subject.call("SESSION-456", "UPO-REF-456")
    end
  end
end
