# frozen_string_literal: true

RSpec.describe KSEF::Requests::Testdata::RegisterPersonHandler do
  subject { described_class.new(http_client) }

  let(:http_client) { stub_http_client(response_body: { "status" => "registered" }) }

  describe "#call" do
    it "registers test person in KSeF" do
      result = subject.call(nip: "1234567890", pesel: "12345678901")

      expect(result).to be_a(Hash)
      expect(result["status"]).to eq("registered")
    end

    it "uses custom description when provided" do
      result = subject.call(nip: "1111111111", pesel: "11111111111", description: "Custom desc")
      expect(result).to be_a(Hash)
    end

    it "includes is_bailiff flag" do
      result = subject.call(nip: "2222222222", pesel: "22222222222", is_bailiff: true)
      expect(result).to be_a(Hash)
    end
  end
end
