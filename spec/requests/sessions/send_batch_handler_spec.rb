# frozen_string_literal: true

RSpec.describe KSEF::Requests::Sessions::SendBatchHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "referenceNumber" => "SESSION-123" }) }

  describe "#call" do
    it "opens batch session" do
      result = subject.call(
        form_code: { systemCode: "FA", schemaVersion: "1-0E", value: "FA(2)" },
        batch_file: { fileSize: 1024, fileHash: "hash123", fileParts: [1] },
        encryption: { encryptedSymmetricKey: "key", initializationVector: "iv" }
      )

      expect(result).to be_a(Hash)
      expect(result["referenceNumber"]).to eq("SESSION-123")
    end

    it "calls POST sessions/batch endpoint" do
      expect(http_client).to receive(:post).with(
        "sessions/batch",
        body: {
          formCode: { systemCode: "FA", schemaVersion: "1-0E", value: "FA(2)" },
          batchFile: { fileSize: 2048 },
          encryption: { encryptedSymmetricKey: "key2" },
          offlineMode: false
        },
        headers: { "Content-Type" => "application/json" }
      ).and_return(double(json: {}))
      subject.call(
        form_code: { systemCode: "FA", schemaVersion: "1-0E", value: "FA(2)" },
        batch_file: { fileSize: 2048 },
        encryption: { encryptedSymmetricKey: "key2" }
      )
    end
  end
end
