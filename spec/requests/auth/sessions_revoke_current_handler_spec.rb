# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::SessionsRevokeCurrentHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "revoked" }) }

  describe "#call" do
    it "revokes current session" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("revoked")
    end

    it "calls DELETE auth/sessions/current endpoint" do
      expect(http_client).to receive(:delete).with("auth/sessions/current").and_return(double(json: {}))
      subject.call
    end
  end
end
