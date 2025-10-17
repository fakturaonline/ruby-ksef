# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Certificates do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:certificates) { described_class.new(http_client) }

  describe "#enrollment_data" do
    it "calls EnrollmentDataHandler" do
      handler = instance_double(KSEF::Requests::Certificates::EnrollmentDataHandler)
      allow(KSEF::Requests::Certificates::EnrollmentDataHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ dn: { cn: "test" } })

      result = certificates.enrollment_data

      expect(result).to eq({ dn: { cn: "test" } })
      expect(handler).to have_received(:call)
    end
  end

  describe "#enroll" do
    it "calls EnrollHandler with params" do
      params = { csr: "base64_csr_data" }
      handler = instance_double(KSEF::Requests::Certificates::EnrollHandler)
      allow(KSEF::Requests::Certificates::EnrollHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(params).and_return({ reference_number: "REF123" })

      result = certificates.enroll(params)

      expect(result).to eq({ reference_number: "REF123" })
      expect(handler).to have_received(:call).with(params)
    end
  end

  describe "#enrollment_status" do
    it "calls EnrollmentStatusHandler with reference number" do
      handler = instance_double(KSEF::Requests::Certificates::EnrollmentStatusHandler)
      allow(KSEF::Requests::Certificates::EnrollmentStatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "completed" })

      result = certificates.enrollment_status("REF123")

      expect(result).to eq({ status: "completed" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#retrieve" do
    it "calls RetrieveHandler with serial numbers" do
      serial_numbers = ["123456", "789012"]
      handler = instance_double(KSEF::Requests::Certificates::RetrieveHandler)
      allow(KSEF::Requests::Certificates::RetrieveHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(serial_numbers).and_return({ certificates: [] })

      result = certificates.retrieve(serial_numbers)

      expect(result).to eq({ certificates: [] })
      expect(handler).to have_received(:call).with(serial_numbers)
    end
  end

  describe "#limits" do
    it "calls LimitsHandler" do
      handler = instance_double(KSEF::Requests::Certificates::LimitsHandler)
      allow(KSEF::Requests::Certificates::LimitsHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ max_certificates: 10 })

      result = certificates.limits

      expect(result).to eq({ max_certificates: 10 })
      expect(handler).to have_received(:call)
    end
  end

  describe "#query" do
    it "calls QueryHandler without params" do
      handler = instance_double(KSEF::Requests::Certificates::QueryHandler)
      allow(KSEF::Requests::Certificates::QueryHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        filters: {},
        page_size: nil,
        page_offset: nil
      ).and_return({ certificates: [] })

      result = certificates.query

      expect(result).to eq({ certificates: [] })
      expect(handler).to have_received(:call)
    end

    it "calls QueryHandler with filters and pagination" do
      filters = { name: "test", status: "active" }
      handler = instance_double(KSEF::Requests::Certificates::QueryHandler)
      allow(KSEF::Requests::Certificates::QueryHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        filters: filters,
        page_size: 20,
        page_offset: 10
      ).and_return({ certificates: [] })

      result = certificates.query(filters: filters, page_size: 20, page_offset: 10)

      expect(result).to eq({ certificates: [] })
      expect(handler).to have_received(:call).with(
        filters: filters,
        page_size: 20,
        page_offset: 10
      )
    end
  end

  describe "#revoke" do
    it "calls RevokeCertificateHandler with serial number" do
      handler = instance_double(KSEF::Requests::Certificates::RevokeCertificateHandler)
      allow(KSEF::Requests::Certificates::RevokeCertificateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("123456", revocation_reason: nil).and_return({ status: "revoked" })

      result = certificates.revoke("123456")

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call).with("123456", revocation_reason: nil)
    end

    it "calls RevokeCertificateHandler with reason" do
      handler = instance_double(KSEF::Requests::Certificates::RevokeCertificateHandler)
      allow(KSEF::Requests::Certificates::RevokeCertificateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("123456", revocation_reason: "compromised").and_return({ status: "revoked" })

      result = certificates.revoke("123456", revocation_reason: "compromised")

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call).with("123456", revocation_reason: "compromised")
    end
  end
end
