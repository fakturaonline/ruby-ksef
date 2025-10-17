# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::EnrollHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "referenceNumber" => "ENROLL-123" }) }

  describe "#call" do
    it "enrolls certificate" do
      result = subject.call(
        certificate_name: "MyCert",
        certificate_type: "RSA",
        csr: "base64csr"
      )

      expect(result).to be_a(Hash)
      expect(result["referenceNumber"]).to eq("ENROLL-123")
    end

    it "calls POST certificates/enrollments endpoint" do
      expect(http_client).to receive(:post).with(
        "certificates/enrollments",
        body: { certificateName: "TestCert", certificateType: "EC", csr: "csrdata" }
      ).and_return(double(json: {}))
      subject.call(certificate_name: "TestCert", certificate_type: "EC", csr: "csrdata")
    end
  end
end
