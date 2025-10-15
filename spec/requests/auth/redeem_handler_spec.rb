# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::RedeemHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: redeem_token_response_fixture) }

  describe "#call" do
    it "returns access and refresh tokens" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("accessToken")
      expect(result).to have_key("refreshToken")

      expect(result["accessToken"]).to have_key("token")
      expect(result["accessToken"]).to have_key("validUntil")

      expect(result["refreshToken"]).to have_key("token")
      expect(result["refreshToken"]).to have_key("validUntil")
    end

    it "calls POST auth/token/redeem endpoint" do
      expect(http_client).to receive(:post).with("auth/token/redeem")
      subject.call
    end
  end
end
