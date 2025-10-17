# frozen_string_literal: true

RSpec.describe KSEF::Requests::Security::PublicKeyHandler do
  subject { described_class.new(http_client) }

  let(:http_client) do
    stub_http_client(response_body: {
      "keys" => [
        { "usage" => "SymmetricKeyEncryption", "certificate" => "base64cert" }
      ]
    })
  end

  describe "#call" do
    it "returns public keys" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("keys")
    end

    it "calls GET security/public-key-certificates endpoint" do
      expect(http_client).to receive(:get).with("security/public-key-certificates").and_return(double(json: {}))
      subject.call
    end
  end
end
