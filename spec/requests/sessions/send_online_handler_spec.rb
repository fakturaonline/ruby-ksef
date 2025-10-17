# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::SendOnlineHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "invoiceReferenceNumber" => "INV-123" }) }

  describe "#call" do
    it "sends online invoice" do
      result = subject.call(
        "SESSION-123",
        invoice_hash: "hash123",
        invoice_size: 1024,
        encrypted_invoice_hash: "enchash",
        encrypted_invoice_size: 1500,
        encrypted_invoice_content: "base64content"
      )

      expect(result).to be_a(Hash)
      expect(result["invoiceReferenceNumber"]).to eq("INV-123")
    end

    it "calls POST sessions/online/{sessionReference}/invoices endpoint" do
      expect(http_client).to receive(:post).with(
        "sessions/online/SESSION-456/invoices",
        body: {
          invoiceHash: "hash456",
          invoiceSize: 2048,
          encryptedInvoiceHash: "enchash456",
          encryptedInvoiceSize: 2500,
          encryptedInvoiceContent: "content456",
          offlineMode: false
        },
        headers: { "Content-Type" => "application/json" }
      ).and_return(double(json: {}))
      subject.call(
        "SESSION-456",
        invoice_hash: "hash456",
        invoice_size: 2048,
        encrypted_invoice_hash: "enchash456",
        encrypted_invoice_size: 2500,
        encrypted_invoice_content: "content456"
      )
    end
  end
end
