# frozen_string_literal: true

RSpec.describe KSEF::Requests::Invoices::ExportsStatusHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "completed" }) }

  describe "#call" do
    it "returns export status" do
      result = subject.call("EXPORT-123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("completed")
    end

    it "calls GET invoices/exports/{referenceNumber} endpoint" do
      expect(http_client).to receive(:get).with("invoices/exports/EXPORT-456").and_return(double(json: {}))
      subject.call("EXPORT-456")
    end
  end
end
