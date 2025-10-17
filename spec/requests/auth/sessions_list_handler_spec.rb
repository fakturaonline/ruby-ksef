# frozen_string_literal: true

RSpec.describe KSEF::Requests::Auth::SessionsListHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "sessions" => [] }) }

  describe "#call" do
    it "returns sessions list without params" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("sessions")
    end

    it "calls GET auth/sessions endpoint" do
      expect(http_client).to receive(:get).with("auth/sessions", params: {}, headers: {}).and_return(double(json: {}))
      subject.call
    end

    it "passes page_size parameter" do
      expect(http_client).to receive(:get).with("auth/sessions", params: { pageSize: 10 }, headers: {}).and_return(double(json: {}))
      subject.call(page_size: 10)
    end

    it "passes continuation_token header" do
      expect(http_client).to receive(:get).with("auth/sessions", params: {}, headers: { "x-continuation-token" => "token123" }).and_return(double(json: {}))
      subject.call(continuation_token: "token123")
    end

    it "passes both params and header" do
      expect(http_client).to receive(:get).with(
        "auth/sessions",
        params: { pageSize: 20 },
        headers: { "x-continuation-token" => "token456" }
      ).and_return(double(json: {}))
      subject.call(page_size: 20, continuation_token: "token456")
    end
  end
end
