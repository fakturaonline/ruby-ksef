# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Invoices do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  let(:config) { instance_double(KSEF::Config) }
  subject(:invoices) { described_class.new(http_client, config) }

  describe "#download" do
    it "calls DownloadHandler with KSEF number" do
      handler = instance_double(KSEF::Requests::Invoices::DownloadHandler)
      allow(KSEF::Requests::Invoices::DownloadHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("1234567890123456789012").and_return("<xml>invoice</xml>")

      result = invoices.download("1234567890123456789012")

      expect(result).to eq("<xml>invoice</xml>")
      expect(handler).to have_received(:call).with("1234567890123456789012")
    end
  end

  describe "#query" do
    it "calls QueryHandler with params" do
      params = { date_from: "2024-01-01", date_to: "2024-01-31" }
      handler = instance_double(KSEF::Requests::Invoices::QueryHandler)
      allow(KSEF::Requests::Invoices::QueryHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(params).and_return({ invoices: [] })

      result = invoices.query(params)

      expect(result).to eq({ invoices: [] })
      expect(handler).to have_received(:call).with(params)
    end
  end

  describe "#status" do
    it "calls StatusHandler with KSEF number" do
      handler = instance_double(KSEF::Requests::Invoices::StatusHandler)
      allow(KSEF::Requests::Invoices::StatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("1234567890123456789012").and_return({ status: "accepted" })

      result = invoices.status("1234567890123456789012")

      expect(result).to eq({ status: "accepted" })
      expect(handler).to have_received(:call).with("1234567890123456789012")
    end
  end

  describe "#exports_init" do
    it "calls ExportsInitHandler with filters" do
      filters = { date_from: "2024-01-01", date_to: "2024-01-31" }
      handler = instance_double(KSEF::Requests::Invoices::ExportsInitHandler)
      allow(KSEF::Requests::Invoices::ExportsInitHandler).to receive(:new).with(http_client, config).and_return(handler)
      allow(handler).to receive(:call).with(filters: filters).and_return({ reference_number: "REF123" })

      result = invoices.exports_init(filters: filters)

      expect(result).to eq({ reference_number: "REF123" })
      expect(handler).to have_received(:call).with(filters: filters)
    end
  end

  describe "#exports_status" do
    it "calls ExportsStatusHandler with operation reference number" do
      handler = instance_double(KSEF::Requests::Invoices::ExportsStatusHandler)
      allow(KSEF::Requests::Invoices::ExportsStatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "completed" })

      result = invoices.exports_status("REF123")

      expect(result).to eq({ status: "completed" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#query_metadata" do
    it "calls QueryMetadataHandler without pagination" do
      filters = { nip: "1234567890" }
      handler = instance_double(KSEF::Requests::Invoices::QueryMetadataHandler)
      allow(KSEF::Requests::Invoices::QueryMetadataHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        filters: filters,
        page_size: nil,
        page_offset: nil
      ).and_return({ invoices: [] })

      result = invoices.query_metadata(filters: filters)

      expect(result).to eq({ invoices: [] })
      expect(handler).to have_received(:call)
    end

    it "calls QueryMetadataHandler with pagination" do
      filters = { nip: "1234567890" }
      handler = instance_double(KSEF::Requests::Invoices::QueryMetadataHandler)
      allow(KSEF::Requests::Invoices::QueryMetadataHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        filters: filters,
        page_size: 50,
        page_offset: 100
      ).and_return({ invoices: [] })

      result = invoices.query_metadata(filters: filters, page_size: 50, page_offset: 100)

      expect(result).to eq({ invoices: [] })
      expect(handler).to have_received(:call).with(
        filters: filters,
        page_size: 50,
        page_offset: 100
      )
    end
  end
end
