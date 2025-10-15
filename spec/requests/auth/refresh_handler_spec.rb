# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::RefreshHandler do
  let(:http_client) { stub_http_client(response_body: refresh_token_response_fixture) }
  subject { described_class.new(http_client) }

  describe "#call" do
    it "returns new access token" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("token")
      expect(result).to have_key("validUntil")
      expect(result["token"]).to start_with("Bearer ")
    end

    it "calls POST auth/token/refresh endpoint" do
      expect(http_client).to receive(:post).with("auth/token/refresh")
      subject.call
    end
  end
end
