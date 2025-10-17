# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::EnrollmentDataHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "enrollments" => [] }) }

  describe "#call" do
    it "returns enrollment data" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result).to have_key("enrollments")
    end

    it "calls GET certificates/enrollments/data endpoint" do
      expect(http_client).to receive(:get).with("certificates/enrollments/data").and_return(double(json: {}))
      subject.call
    end
  end
end
