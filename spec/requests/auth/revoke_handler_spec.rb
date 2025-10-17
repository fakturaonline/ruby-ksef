# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::RevokeHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "revoked" }) }

  describe "#call" do
    it "returns revocation response" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("revoked")
    end

    it "calls DELETE auth/token endpoint" do
      expect(http_client).to receive(:delete).with("auth/token").and_return(double(json: {}))
      subject.call
    end
  end
end
