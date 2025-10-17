# frozen_string_literal: true

RSpec.describe KSEF::Requests::Invoices::StatusHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "accepted", "invoiceNumber" => "INV123" }) }

  describe "#call" do
    it "returns invoice data by KSEF number" do
      result = subject.call("1234567890-20250101-ABCD1234567890-12")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("accepted")
    end

    it "calls GET invoices/ksef/{ksefNumber} endpoint" do
      expect(http_client).to receive(:get).with("invoices/ksef/1111111111-20250101-XXXX1111111111-11").and_return(double(json: {}))
      subject.call("1111111111-20250101-XXXX1111111111-11")
    end
  end
end
