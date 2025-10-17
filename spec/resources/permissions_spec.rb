# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Permissions do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:permissions) { described_class.new(http_client) }

  describe "#grant_persons" do
    it "delegates to PersonsGrantsHandler" do
      handler = instance_double(KSEF::Requests::Permissions::PersonsGrantsHandler)
      allow(KSEF::Requests::Permissions::PersonsGrantsHandler).to receive(:new).with(http_client).and_return(handler)

      grant_data = { nip: "1234567890", persons: [] }
      expect(handler).to receive(:call).with(grant_data: grant_data).and_return({ "referenceNumber" => "123" })

      result = permissions.grant_persons(grant_data: grant_data)
      expect(result).to eq({ "referenceNumber" => "123" })
    end
  end

  describe "#grant_entities" do
    it "delegates to EntitiesGrantsHandler" do
      handler = instance_double(KSEF::Requests::Permissions::EntitiesGrantsHandler)
      allow(KSEF::Requests::Permissions::EntitiesGrantsHandler).to receive(:new).with(http_client).and_return(handler)

      grant_data = { nip: "1234567890", entities: [] }
      expect(handler).to receive(:call).with(grant_data: grant_data).and_return({ "referenceNumber" => "456" })

      result = permissions.grant_entities(grant_data: grant_data)
      expect(result).to eq({ "referenceNumber" => "456" })
    end
  end

  describe "#revoke_common_grant" do
    it "delegates to CommonGrantsRevokeHandler" do
      handler = instance_double(KSEF::Requests::Permissions::CommonGrantsRevokeHandler)
      allow(KSEF::Requests::Permissions::CommonGrantsRevokeHandler).to receive(:new).with(http_client).and_return(handler)

      expect(handler).to receive(:call).with("perm_123").and_return({ "status" => "revoked" })

      result = permissions.revoke_common_grant("perm_123")
      expect(result).to eq({ "status" => "revoked" })
    end
  end

  describe "#query_personal_grants" do
    it "delegates to QueryPersonalGrantsHandler" do
      handler = instance_double(KSEF::Requests::Permissions::QueryPersonalGrantsHandler)
      allow(KSEF::Requests::Permissions::QueryPersonalGrantsHandler).to receive(:new).with(http_client).and_return(handler)

      query_data = { permission_type: "read" }
      expect(handler).to receive(:call).with(
        query_data: query_data,
        page_size: 20,
        page_offset: 0
      ).and_return({ "grants" => [] })

      result = permissions.query_personal_grants(query_data: query_data, page_size: 20, page_offset: 0)
      expect(result).to eq({ "grants" => [] })
    end
  end

  describe "#operation_status" do
    it "delegates to OperationsStatusHandler" do
      handler = instance_double(KSEF::Requests::Permissions::OperationsStatusHandler)
      allow(KSEF::Requests::Permissions::OperationsStatusHandler).to receive(:new).with(http_client).and_return(handler)

      expect(handler).to receive(:call).with("ref_123").and_return({ "status" => "completed" })

      result = permissions.operation_status("ref_123")
      expect(result).to eq({ "status" => "completed" })
    end
  end
end
