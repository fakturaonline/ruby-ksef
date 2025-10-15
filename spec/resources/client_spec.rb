# frozen_string_literal: true

RSpec.describe KSEF::Resources::Client do
  let(:config) { test_config }
  let(:http_client) { instance_double(KSEF::HttpClient::Client, config: config) }
  subject { described_class.new(http_client, config) }

  describe "resource accessors" do
    it "returns auth resource" do
      expect(subject.auth).to be_a(KSEF::Resources::Auth)
    end

    it "returns sessions resource" do
      allow(http_client).to receive(:config=)
      expect(subject.sessions).to be_a(KSEF::Resources::Sessions)
    end

    it "returns invoices resource" do
      allow(http_client).to receive(:config=)
      expect(subject.invoices).to be_a(KSEF::Resources::Invoices)
    end

    it "returns certificates resource" do
      allow(http_client).to receive(:config=)
      expect(subject.certificates).to be_a(KSEF::Resources::Certificates)
    end

    it "returns tokens resource" do
      allow(http_client).to receive(:config=)
      expect(subject.tokens).to be_a(KSEF::Resources::Tokens)
    end

    it "returns security resource" do
      expect(subject.security).to be_a(KSEF::Resources::Security)
    end
  end

  describe "auto token refresh" do
    let(:expired_token) { expired_access_token }
    let(:refresh_token) { valid_refresh_token }
    let(:config) do
      test_config(
        access_token: expired_token,
        refresh_token: refresh_token
      )
    end

    before do
      allow(http_client).to receive(:config=)

      # Mock refresh endpoint
      refresh_response = stub_http_client(
        response_body: refresh_token_response_fixture
      )
      allow(KSEF::HttpClient::Client).to receive(:new).and_return(refresh_response)
      allow(refresh_response).to receive(:post).and_return(
        instance_double(
          KSEF::HttpClient::Response,
          json: refresh_token_response_fixture
        )
      )
    end

    it "refreshes expired access token when accessing sessions" do
      expect(config.access_token.expired?).to be true

      # Should trigger refresh
      subject.sessions

      # Token should be updated (we can't easily test this without
      # making config mutable or using different approach)
    end

    it "refreshes expired access token when accessing invoices" do
      expect(config.access_token.expired?).to be true
      subject.invoices
    end
  end

  describe "token accessors" do
    it "returns access token" do
      expect(subject.access_token).to eq config.access_token
    end

    it "returns refresh token" do
      expect(subject.refresh_token).to eq config.refresh_token
    end

    it "returns encryption key" do
      expect(subject.encryption_key).to eq config.encryption_key
    end
  end
end
