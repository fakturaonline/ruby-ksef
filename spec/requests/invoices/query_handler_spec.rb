# frozen_string_literal: true

RSpec.describe KSEF::Requests::Invoices::QueryHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: invoice_query_response_fixture) }
  let(:params) do
    {
      from_date: "2025-01-01",
      to_date: "2025-01-31",
      invoice_type: "sent"
    }
  end

  describe "#call" do
    it "returns list of invoices" do
      result = subject.call(params)

      expect(result).to be_a(Hash)
      expect(result).to have_key("invoices")
      expect(result).to have_key("totalCount")
      expect(result["invoices"]).to be_an(Array)
      expect(result["invoices"].length).to eq 3
    end

    it "returns invoice details" do
      result = subject.call(params)
      invoice = result["invoices"].first

      expect(invoice).to have_key("ksefNumber")
      expect(invoice).to have_key("invoiceNumber")
      expect(invoice).to have_key("amount")
      expect(invoice).to have_key("currency")
      expect(invoice).to have_key("date")
    end

    it "calls POST invoices/query endpoint" do
      expect(http_client).to receive(:post).with("invoices/query/metadata", body: params)
      subject.call(params)
    end
  end
end
