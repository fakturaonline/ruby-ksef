# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::RevokeCertificateHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "revoked" }) }

  describe "#call" do
    it "revokes certificate without reason" do
      result = subject.call("CERT123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("revoked")
    end

    it "calls POST certificates/{serialNumber}/revoke endpoint" do
      expect(http_client).to receive(:post).with(
        "certificates/CERT456/revoke",
        body: {}
      ).and_return(double(json: {}))
      subject.call("CERT456")
    end

    it "includes revocation reason when provided" do
      expect(http_client).to receive(:post).with(
        "certificates/CERT789/revoke",
        body: { revocationReason: "Compromised" }
      ).and_return(double(json: {}))
      subject.call("CERT789", revocation_reason: "Compromised")
    end
  end
end
