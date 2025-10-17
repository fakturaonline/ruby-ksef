# frozen_string_literal: true

RSpec.describe KSEF::Requests::Tokens::CreateHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "referenceNumber" => "TOKEN-REF-123" }) }

  describe "#call" do
    it "creates token with permissions" do
      result = subject.call(permissions: ["InvoiceRead"], description: "Test token")

      expect(result).to be_a(Hash)
      expect(result["referenceNumber"]).to eq("TOKEN-REF-123")
    end

    it "calls POST tokens endpoint" do
      expect(http_client).to receive(:post).with(
        "tokens",
        body: { permissions: ["InvoiceWrite"], description: "My token" }
      ).and_return(double(json: {}))
      subject.call(permissions: ["InvoiceWrite"], description: "My token")
    end
  end
end
