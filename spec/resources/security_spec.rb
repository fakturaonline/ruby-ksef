# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Security do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:security) { described_class.new(http_client) }

  describe "#public_keys" do
    it "calls PublicKeyHandler" do
      handler = instance_double(KSEF::Requests::Security::PublicKeyHandler)
      allow(KSEF::Requests::Security::PublicKeyHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return([
                                                     { key_id: "key1", certificate: "cert1" },
                                                     { key_id: "key2", certificate: "cert2" }
                                                   ])

      result = security.public_keys

      expect(result).to eq([
                             { key_id: "key1", certificate: "cert1" },
                             { key_id: "key2", certificate: "cert2" }
                           ])
      expect(handler).to have_received(:call)
    end
  end
end
