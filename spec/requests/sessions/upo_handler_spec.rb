# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoHandler do
  subject { described_class.new(http_client) }

  let(:upo_xml) { '<?xml version="1.0"?><UPO><ReferenceNumber>12345</ReferenceNumber></UPO>' }
  let(:http_client) { stub_http_client(response_body: upo_xml) }

  describe "#call" do
    it "returns UPO XML as string" do
      result = subject.call("SESSION-123", "UPO-REF-123")

      expect(result).to be_a(String)
      expect(result).to include("<UPO>")
      expect(result).to include("<ReferenceNumber>12345</ReferenceNumber>")
    end

    it "calls GET sessions/{sessionReference}/upo/{upoReference} endpoint" do
      expect(http_client).to receive(:get).with("sessions/SESSION-456/upo/UPO-REF-456").and_return(double(body: upo_xml))
      subject.call("SESSION-456", "UPO-REF-456")
    end
  end
end
