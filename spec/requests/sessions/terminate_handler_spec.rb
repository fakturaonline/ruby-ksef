# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::TerminateHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "terminated" }) }

  describe "#call" do
    it "terminates session" do
      result = subject.call("SESSION-123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("terminated")
    end

    it "calls DELETE sessions/{referenceNumber} endpoint" do
      expect(http_client).to receive(:delete).with("sessions/SESSION-456").and_return(double(json: {}))
      subject.call("SESSION-456")
    end
  end
end
