# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::UpoByKsefNumberHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "upoData" => "base64data" }) }

  describe "#call" do
    it "returns UPO by KSEF number" do
      result = subject.call("SESSION-123", "1234567890-20250101-ABCD1234567890-12")

      expect(result).to be_a(Hash)
      expect(result["upoData"]).to eq("base64data")
    end

    it "calls GET sessions/{sessionReference}/invoices/ksef/{ksefNumber}/upo endpoint" do
      ksef_number = "1111111111-20250101-XXXX1111111111-11"
      expect(http_client).to receive(:get).with("sessions/SESSION-456/invoices/ksef/#{ksef_number}/upo").and_return(double(json: {}))
      subject.call("SESSION-456", ksef_number)
    end
  end
end
