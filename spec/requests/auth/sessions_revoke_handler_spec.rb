# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::SessionsRevokeHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "revoked" }) }

  describe "#call" do
    it "revokes specific session" do
      result = subject.call("REF123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("revoked")
    end

    it "calls DELETE auth/sessions/{referenceNumber} endpoint" do
      expect(http_client).to receive(:delete).with("auth/sessions/REF456").and_return(double(json: {}))
      subject.call("REF456")
    end
  end
end
