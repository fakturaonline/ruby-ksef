# frozen_string_literal: true

RSpec.describe KSEF::Requests::Invoices::DownloadHandler do
  subject { described_class.new(http_client) }

  let(:response) { double(body: "<Invoice>XML data</Invoice>") }
  let(:http_client) do
    client = instance_double(KSEF::HttpClient::Client)
    allow(client).to receive(:get).and_return(response)
    client
  end

  describe "#call" do
    it "downloads invoice XML" do
      result = subject.call("1234567890-20250101-ABCD1234567890-12")

      expect(result).to eq("<Invoice>XML data</Invoice>")
    end

    it "calls GET invoices/ksef/{ksefNumber} endpoint" do
      expect(http_client).to receive(:get).with("invoices/ksef/1111111111-20250101-XXXX1111111111-11").and_return(response)
      subject.call("1111111111-20250101-XXXX1111111111-11")
    end
  end
end
