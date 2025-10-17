# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::RetrieveHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "certificates" => [] }) }

  describe "#call" do
    it "retrieves certificates by serial numbers" do
      result = subject.call(["123", "456"])

      expect(result).to be_a(Hash)
      expect(result).to have_key("certificates")
    end

    it "calls POST certificates/retrieve endpoint" do
      expect(http_client).to receive(:post).with(
        "certificates/retrieve",
        body: { certificateSerialNumbers: ["789", "012"] }
      ).and_return(double(json: {}))
      subject.call(["789", "012"])
    end
  end
end
