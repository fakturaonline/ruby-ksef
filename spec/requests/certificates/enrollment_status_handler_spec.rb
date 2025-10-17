# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::EnrollmentStatusHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "completed" }) }

  describe "#call" do
    it "returns enrollment status" do
      result = subject.call("ENROLL-123")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("completed")
    end

    it "calls GET certificates/enrollments/{referenceNumber} endpoint" do
      expect(http_client).to receive(:get).with("certificates/enrollments/ENROLL-456").and_return(double(json: {}))
      subject.call("ENROLL-456")
    end
  end
end
