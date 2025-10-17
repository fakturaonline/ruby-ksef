# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::InvoiceHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "invoiceNumber" => "INV-123" }) }

  describe "#call" do
    it "returns invoice details" do
      result = subject.call("SESSION-123", "INV-REF-123")

      expect(result).to be_a(Hash)
      expect(result["invoiceNumber"]).to eq("INV-123")
    end

    it "calls GET sessions/{sessionReference}/invoices/{invoiceReference} endpoint" do
      expect(http_client).to receive(:get).with("sessions/SESSION-456/invoices/INV-REF-456").and_return(double(json: {}))
      subject.call("SESSION-456", "INV-REF-456")
    end
  end
end
