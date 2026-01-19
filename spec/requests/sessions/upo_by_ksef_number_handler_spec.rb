# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoByKsefNumberHandler do
  subject { described_class.new(http_client) }

  let(:upo_xml) { '<?xml version="1.0"?><UPO><ReferenceNumber>12345</ReferenceNumber></UPO>' }
  let(:http_client) { stub_http_client(response_body: upo_xml) }

  describe "#call" do
    it "returns UPO XML as string" do
      result = subject.call("SESSION-123", "1234567890-20250101-ABCD1234567890-12")

      expect(result).to be_a(String)
      expect(result).to include("<UPO>")
      expect(result).to include("<ReferenceNumber>12345</ReferenceNumber>")
    end

    it "calls GET sessions/{sessionReference}/invoices/ksef/{ksefNumber}/upo endpoint" do
      ksef_number = "1111111111-20250101-XXXX1111111111-11"
      expect(http_client).to receive(:get).with("sessions/SESSION-456/invoices/ksef/#{ksef_number}/upo").and_return(double(body: upo_xml))
      subject.call("SESSION-456", ksef_number)
    end
  end
end
