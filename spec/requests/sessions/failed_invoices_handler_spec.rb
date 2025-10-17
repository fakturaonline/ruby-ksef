# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::FailedInvoicesHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "failedInvoices" => [] }) }

  describe "#call" do
    it "returns failed invoices list" do
      result = subject.call("SESSION-123")

      expect(result).to be_a(Hash)
      expect(result).to have_key("failedInvoices")
    end

    it "calls GET sessions/{sessionReference}/invoices/failed endpoint" do
      expect(http_client).to receive(:get).with(
        "sessions/SESSION-456/invoices/failed",
        params: {}
      ).and_return(double(json: {}))
      subject.call("SESSION-456")
    end

    it "passes params" do
      expect(http_client).to receive(:get).with(
        "sessions/SESSION-789/invoices/failed",
        params: { pageSize: 10 }
      ).and_return(double(json: {}))
      subject.call("SESSION-789", pageSize: 10)
    end
  end
end
