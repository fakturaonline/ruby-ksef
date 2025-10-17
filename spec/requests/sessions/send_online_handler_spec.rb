# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::SendOnlineHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: send_online_response_fixture) }
  let(:reference_number) { "20250625-EE-319D7EE000-B67F415CDC-2C" }
  let(:invoice_xml) { invoice_xml_fixture }
  let(:encrypted_content) { "encrypted_invoice_content" }
  let(:params) do
    {
      invoice_hash: Base64.strict_encode64(Digest::SHA256.digest(invoice_xml)),
      invoice_size: invoice_xml.bytesize,
      encrypted_invoice_hash: Base64.strict_encode64(Digest::SHA256.digest(encrypted_content)),
      encrypted_invoice_size: encrypted_content.bytesize,
      encrypted_invoice_content: Base64.strict_encode64(encrypted_content),
      offline_mode: false
    }
  end

  describe "#call" do
    it "returns send response with reference number" do
      result = subject.call(reference_number, params)

      expect(result).to be_a(Hash)
      expect(result).to have_key("referenceNumber")
      expect(result).to have_key("timestamp")
      expect(result["referenceNumber"]).to match(/\d{8}-[A-Z]+-[A-Z0-9-]+/)
    end

    it "calls POST sessions/online/{referenceNumber}/invoices endpoint" do
      expect(http_client).to receive(:post).with(
        "sessions/online/#{reference_number}/invoices",
        hash_including(body: anything)
      )
      subject.call(reference_number, params)
    end

    it "sends correct request body" do
      expect(http_client).to receive(:post) do |_path, options|
        expect(options[:body]).to include(
          invoiceHash: params[:invoice_hash],
          invoiceSize: params[:invoice_size],
          encryptedInvoiceHash: params[:encrypted_invoice_hash],
          encryptedInvoiceSize: params[:encrypted_invoice_size],
          encryptedInvoiceContent: params[:encrypted_invoice_content],
          offlineMode: false
        )

        # Return proper response
        instance_double(
          KSEF::HttpClient::Response,
          json: send_online_response_fixture
        )
      end

      subject.call(reference_number, params)
    end
  end
end
