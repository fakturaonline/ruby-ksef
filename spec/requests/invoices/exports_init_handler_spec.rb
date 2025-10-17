# frozen_string_literal: true

RSpec.describe KSEF::Requests::Invoices::ExportsInitHandler do
  let(:encryption_key) { double(key: "encrypted_key", iv: "initialization_vector") }
  let(:config) { double(encryption_key: encryption_key) }
  let(:http_client) { stub_http_client(response_body: { "referenceNumber" => "EXPORT-123" }) }

  subject { described_class.new(http_client, config) }

  describe "#call" do
    it "initializes export with filters and encryption" do
      result = subject.call(
        filters: {
          subject_type: "subject1",
          date_range: { from: "2025-01-01", to: "2025-12-31" }
        }
      )

      expect(result).to be_a(Hash)
      expect(result["referenceNumber"]).to eq("EXPORT-123")
    end

    it "calls POST invoices/exports endpoint with encryption" do
      expect(http_client).to receive(:post).with(
        "invoices/exports",
        body: {
          filters: { subjectType: "subject2", dateRange: { from: "2024-01-01", to: "2024-12-31" } },
          encryption: { encryptedSymmetricKey: "encrypted_key", initializationVector: "initialization_vector" }
        }
      ).and_return(double(json: {}))
      subject.call(filters: { subject_type: "subject2", date_range: { from: "2024-01-01", to: "2024-12-31" } })
    end

    it "raises error if encryption_key is missing" do
      config_without_key = double(encryption_key: nil)
      handler = described_class.new(http_client, config_without_key)

      expect {
        handler.call(filters: { subject_type: "subject1" })
      }.to raise_error("Encrypted key is required")
    end
  end
end
