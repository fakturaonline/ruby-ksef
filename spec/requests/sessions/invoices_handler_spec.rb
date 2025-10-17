# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::InvoicesHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "invoices" => [] }) }

  describe "#call" do
    it "returns invoices list" do
      result = subject.call("SESSION-123")

      expect(result).to be_a(Hash)
      expect(result).to have_key("invoices")
    end

    it "calls GET sessions/{sessionReference}/invoices endpoint" do
      expect(http_client).to receive(:get).with(
        "sessions/SESSION-456/invoices",
        params: {}
      ).and_return(double(json: {}))
      subject.call("SESSION-456")
    end

    it "passes params" do
      expect(http_client).to receive(:get).with(
        "sessions/SESSION-789/invoices",
        params: { pageSize: 20, pageOffset: 40 }
      ).and_return(double(json: {}))
      subject.call("SESSION-789", pageSize: 20, pageOffset: 40)
    end
  end
end
