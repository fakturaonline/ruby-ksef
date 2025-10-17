# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoByInvoiceReferenceHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "upoData" => "base64data" }) }

  describe "#call" do
    it "returns UPO by invoice reference" do
      result = subject.call("SESSION-123", "INV-REF-123")

      expect(result).to be_a(Hash)
      expect(result["upoData"]).to eq("base64data")
    end

    it "calls GET sessions/{sessionReference}/invoices/{invoiceReference}/upo endpoint" do
      expect(http_client).to receive(:get).with("sessions/SESSION-456/invoices/INV-REF-456/upo").and_return(double(json: {}))
      subject.call("SESSION-456", "INV-REF-456")
    end
  end
end
