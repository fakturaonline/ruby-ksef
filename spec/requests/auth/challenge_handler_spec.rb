# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::ChallengeHandler do
  let(:http_client) { stub_http_client(response_body: challenge_response_fixture) }
  subject { described_class.new(http_client) }

  describe "#call" do
    it "returns challenge data" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("challenge")
      expect(result).to have_key("timestamp")
      expect(result["challenge"]).to be_a(String)
      expect(result["timestamp"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it "calls GET auth/challenge endpoint" do
      expect(http_client).to receive(:get).with("auth/challenge")
      subject.call
    end
  end
end
