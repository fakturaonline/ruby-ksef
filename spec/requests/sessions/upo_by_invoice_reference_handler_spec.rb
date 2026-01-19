# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoByInvoiceReferenceHandler do
  subject { described_class.new(http_client) }

  let(:upo_xml) { '<?xml version="1.0"?><UPO><ReferenceNumber>12345</ReferenceNumber></UPO>' }
  let(:http_client) { stub_http_client(response_body: upo_xml) }

  describe "#call" do
    it "returns UPO XML as string" do
      result = subject.call("SESSION-123", "INV-REF-123")

      expect(result).to be_a(String)
      expect(result).to include("<UPO>")
      expect(result).to include("<ReferenceNumber>12345</ReferenceNumber>")
    end

    it "calls GET sessions/{sessionReference}/invoices/{invoiceReference}/upo endpoint" do
      expect(http_client).to receive(:get).with("sessions/SESSION-456/invoices/INV-REF-456/upo").and_return(double(body: upo_xml))
      subject.call("SESSION-456", "INV-REF-456")
    end
  end
end
