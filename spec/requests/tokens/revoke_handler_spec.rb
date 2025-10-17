# frozen_string_literal: true

RSpec.describe KSEF::Requests::Tokens::RevokeHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "revoked" }) }

  describe "#call" do
    it "revokes token" do
      result = subject.call("TOKEN123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("revoked")
    end

    it "calls DELETE tokens/{tokenNumber} endpoint" do
      expect(http_client).to receive(:delete).with("tokens/TOKEN456").and_return(double(json: {}))
      subject.call("TOKEN456")
    end
  end
end
