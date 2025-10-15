# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::StatusHandler do
  let(:reference_number) { "20250115-SE-ABCDEF123456" }
  let(:http_client) { stub_http_client(response_body: auth_status_response_fixture) }
  subject { described_class.new(http_client) }

  describe "#call" do
    it "returns status data" do
      result = subject.call(reference_number)

      expect(result).to be_a(Hash)
      expect(result).to have_key("referenceNumber")
      expect(result).to have_key("status")
      expect(result["status"]).to have_key("code")
      expect(result["status"]["code"]).to eq 200
    end

    it "calls GET auth/{referenceNumber} endpoint" do
      expect(http_client).to receive(:get).with("auth/#{reference_number}")
      subject.call(reference_number)
    end

    context "when processing" do
      let(:http_client) do
        stub_http_client(response_body: auth_status_response_fixture(code: 102))
      end

      it "returns processing status" do
        result = subject.call(reference_number)
        expect(result["status"]["code"]).to eq 102
      end
    end
  end
end
