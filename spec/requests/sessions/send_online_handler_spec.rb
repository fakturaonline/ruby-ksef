# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::SendOnlineHandler do
  let(:http_client) { stub_http_client(response_body: send_online_response_fixture) }
  subject { described_class.new(http_client) }

  let(:params) do
    {
      invoice_hash: Digest::SHA256.base64digest(invoice_xml_fixture),
      invoice_payload: Base64.strict_encode64(invoice_xml_fixture)
    }
  end

  describe "#call" do
    it "returns send response with reference number" do
      result = subject.call(params)

      expect(result).to be_a(Hash)
      expect(result).to have_key("referenceNumber")
      expect(result).to have_key("timestamp")
      expect(result["referenceNumber"]).to match(/\d{8}-SE-[A-Z0-9]+/)
    end

    it "calls POST online/invoices/send endpoint" do
      expect(http_client).to receive(:post).with(
        "online/invoices/send",
        hash_including(body: anything)
      )
      subject.call(params)
    end

    it "sends invoice hash and payload" do
      expect(http_client).to receive(:post) do |_path, options|
        expect(options[:body]).to include(
          invoiceHash: params[:invoice_hash],
          invoicePayload: params[:invoice_payload]
        )

        # Return proper response
        instance_double(
          KSEF::HttpClient::Response,
          json: send_online_response_fixture
        )
      end

      subject.call(params)
    end
  end
end
