# frozen_string_literal: true

RSpec.describe KSEF::Requests::Tokens::ListHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "tokens" => [] }) }

  describe "#call" do
    it "returns tokens list" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("tokens")
    end

    it "calls GET tokens endpoint" do
      expect(http_client).to receive(:get).with("tokens").and_return(double(json: {}))
      subject.call
    end
  end
end
