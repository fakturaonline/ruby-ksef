# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::CloseBatchHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "closed" }) }

  describe "#call" do
    it "closes batch session" do
      result = subject.call("SESSION-123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("closed")
    end

    it "calls POST sessions/batch/{sessionReference}/close endpoint" do
      expect(http_client).to receive(:post).with("sessions/batch/SESSION-456/close").and_return(double(json: {}))
      subject.call("SESSION-456")
    end
  end
end
