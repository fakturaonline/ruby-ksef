# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Testdata do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:testdata) { described_class.new(http_client) }

  describe "#person_create" do
    it "calls PersonCreateHandler with required params" do
      handler = instance_double(KSEF::Requests::Testdata::PersonCreateHandler)
      allow(KSEF::Requests::Testdata::PersonCreateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        nip: "1234567890",
        pesel: "12345678901",
        description: "Test person",
        is_bailiff: false,
        created_date: nil
      ).and_return({ status: "created" })

      result = testdata.person_create(
        nip: "1234567890",
        pesel: "12345678901",
        description: "Test person"
      )

      expect(result).to eq({ status: "created" })
      expect(handler).to have_received(:call)
    end

    it "calls PersonCreateHandler with all params" do
      handler = instance_double(KSEF::Requests::Testdata::PersonCreateHandler)
      allow(KSEF::Requests::Testdata::PersonCreateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        nip: "1234567890",
        pesel: "12345678901",
        description: "Test bailiff",
        is_bailiff: true,
        created_date: "2024-01-01T00:00:00Z"
      ).and_return({ status: "created" })

      result = testdata.person_create(
        nip: "1234567890",
        pesel: "12345678901",
        description: "Test bailiff",
        is_bailiff: true,
        created_date: "2024-01-01T00:00:00Z"
      )

      expect(result).to eq({ status: "created" })
      expect(handler).to have_received(:call).with(
        nip: "1234567890",
        pesel: "12345678901",
        description: "Test bailiff",
        is_bailiff: true,
        created_date: "2024-01-01T00:00:00Z"
      )
    end
  end

  describe "#person_remove" do
    it "calls PersonRemoveHandler with NIP" do
      handler = instance_double(KSEF::Requests::Testdata::PersonRemoveHandler)
      allow(KSEF::Requests::Testdata::PersonRemoveHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(nip: "1234567890").and_return({ status: "removed" })

      result = testdata.person_remove(nip: "1234567890")

      expect(result).to eq({ status: "removed" })
      expect(handler).to have_received(:call).with(nip: "1234567890")
    end
  end
end
