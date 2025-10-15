# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::StatusHandler do
  subject { described_class.new(http_client) }

  let(:reference_number) { "20250115-SE-ABCDEF123456" }
  let(:http_client) { stub_http_client(response_body: session_status_response_fixture) }

  describe "#call" do
    it "returns session status" do
      result = subject.call(reference_number)

      expect(result).to be_a(Hash)
      expect(result).to have_key("referenceNumber")
      expect(result).to have_key("status")
      expect(result["status"]["code"]).to eq 200
    end

    it "returns KSEF number when accepted" do
      result = subject.call(reference_number)
      expect(result).to have_key("ksefNumber")
      expect(result["ksefNumber"]).to match(/\d{10}-\d{8}-[A-Z0-9]+-\d{2}/)
    end

    it "calls GET sessions/{referenceNumber} endpoint" do
      expect(http_client).to receive(:get).with("sessions/#{reference_number}")
      subject.call(reference_number)
    end

    context "when still processing" do
      let(:http_client) do
        stub_http_client(response_body: session_status_response_fixture(code: 102))
      end

      it "returns processing status without KSEF number" do
        result = subject.call(reference_number)
        expect(result["status"]["code"]).to eq 102
        expect(result).not_to have_key("ksefNumber")
      end
    end
  end
end
