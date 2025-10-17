# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Tokens do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:tokens) { described_class.new(http_client) }

  describe "#create" do
    it "calls CreateHandler with permissions and description" do
      permissions = ["InvoiceRead", "InvoiceWrite"]
      handler = instance_double(KSEF::Requests::Tokens::CreateHandler)
      allow(KSEF::Requests::Tokens::CreateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(
        permissions: permissions,
        description: "Test token"
      ).and_return({ reference_number: "REF123" })

      result = tokens.create(permissions: permissions, description: "Test token")

      expect(result).to eq({ reference_number: "REF123" })
      expect(handler).to have_received(:call).with(
        permissions: permissions,
        description: "Test token"
      )
    end
  end

  describe "#list" do
    it "calls ListHandler" do
      handler = instance_double(KSEF::Requests::Tokens::ListHandler)
      allow(KSEF::Requests::Tokens::ListHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ tokens: [] })

      result = tokens.list

      expect(result).to eq({ tokens: [] })
      expect(handler).to have_received(:call)
    end
  end

  describe "#status" do
    it "calls StatusHandler with reference number" do
      handler = instance_double(KSEF::Requests::Tokens::StatusHandler)
      allow(KSEF::Requests::Tokens::StatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "active" })

      result = tokens.status("REF123")

      expect(result).to eq({ status: "active" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#revoke" do
    it "calls RevokeHandler with token number" do
      handler = instance_double(KSEF::Requests::Tokens::RevokeHandler)
      allow(KSEF::Requests::Tokens::RevokeHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("TOKEN123").and_return({ status: "revoked" })

      result = tokens.revoke("TOKEN123")

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call).with("TOKEN123")
    end
  end
end
