# frozen_string_literal: true

RSpec.describe KSEF::Requests::Certificates::LimitsHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "maxCertificates" => 10 }) }

  describe "#call" do
    it "returns certificate limits" do
      result = subject.call

      expect(result).to be_a(Hash)
      expect(result["maxCertificates"]).to eq(10)
    end

    it "calls GET certificates/limits endpoint" do
      expect(http_client).to receive(:get).with("certificates/limits").and_return(double(json: {}))
      subject.call
    end
  end
end
