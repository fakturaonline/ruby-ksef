# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::RefreshHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "accessToken" => { "token" => "new_token", "validUntil" => "2025-01-01T00:00:00Z" } }) }

  describe "#call" do
    it "returns new access token" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("accessToken")
      expect(result["accessToken"]["token"]).to eq("new_token")
    end

    it "calls POST auth/token/refresh endpoint" do
      expect(http_client).to receive(:post).with("auth/token/refresh").and_return(double(json: {}))
      subject.call
    end
  end
end
