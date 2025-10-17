# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Auth do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:auth) { described_class.new(http_client) }

  describe "#challenge" do
    it "calls ChallengeHandler" do
      handler = instance_double(KSEF::Requests::Auth::ChallengeHandler)
      allow(KSEF::Requests::Auth::ChallengeHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ challenge: "test_challenge" })

      result = auth.challenge

      expect(result).to eq({ challenge: "test_challenge" })
      expect(handler).to have_received(:call)
    end
  end

  describe "#status" do
    it "calls StatusHandler with reference number" do
      handler = instance_double(KSEF::Requests::Auth::StatusHandler)
      allow(KSEF::Requests::Auth::StatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "approved" })

      result = auth.status("REF123")

      expect(result).to eq({ status: "approved" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#redeem" do
    it "calls RedeemHandler" do
      handler = instance_double(KSEF::Requests::Auth::RedeemHandler)
      allow(KSEF::Requests::Auth::RedeemHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({
                                                     access_token: "access123",
                                                     refresh_token: "refresh123"
                                                   })

      result = auth.redeem

      expect(result).to eq({
                             access_token: "access123",
                             refresh_token: "refresh123"
                           })
      expect(handler).to have_received(:call)
    end
  end

  describe "#refresh" do
    it "calls RefreshHandler" do
      handler = instance_double(KSEF::Requests::Auth::RefreshHandler)
      allow(KSEF::Requests::Auth::RefreshHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ access_token: "new_access123" })

      result = auth.refresh

      expect(result).to eq({ access_token: "new_access123" })
      expect(handler).to have_received(:call)
    end
  end

  describe "#revoke" do
    it "calls RevokeHandler" do
      handler = instance_double(KSEF::Requests::Auth::RevokeHandler)
      allow(KSEF::Requests::Auth::RevokeHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ status: "revoked" })

      result = auth.revoke

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call)
    end
  end

  describe "#sessions_list" do
    it "calls SessionsListHandler without params" do
      handler = instance_double(KSEF::Requests::Auth::SessionsListHandler)
      allow(KSEF::Requests::Auth::SessionsListHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(page_size: nil, continuation_token: nil).and_return({ sessions: [] })

      result = auth.sessions_list

      expect(result).to eq({ sessions: [] })
      expect(handler).to have_received(:call).with(page_size: nil, continuation_token: nil)
    end

    it "calls SessionsListHandler with params" do
      handler = instance_double(KSEF::Requests::Auth::SessionsListHandler)
      allow(KSEF::Requests::Auth::SessionsListHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(page_size: 10, continuation_token: "token123").and_return({ sessions: [] })

      result = auth.sessions_list(page_size: 10, continuation_token: "token123")

      expect(result).to eq({ sessions: [] })
      expect(handler).to have_received(:call).with(page_size: 10, continuation_token: "token123")
    end
  end

  describe "#sessions_revoke" do
    it "calls SessionsRevokeHandler with reference number" do
      handler = instance_double(KSEF::Requests::Auth::SessionsRevokeHandler)
      allow(KSEF::Requests::Auth::SessionsRevokeHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF456").and_return({ status: "revoked" })

      result = auth.sessions_revoke("REF456")

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call).with("REF456")
    end
  end

  describe "#sessions_revoke_current" do
    it "calls SessionsRevokeCurrentHandler" do
      handler = instance_double(KSEF::Requests::Auth::SessionsRevokeCurrentHandler)
      allow(KSEF::Requests::Auth::SessionsRevokeCurrentHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).and_return({ status: "revoked" })

      result = auth.sessions_revoke_current

      expect(result).to eq({ status: "revoked" })
      expect(handler).to have_received(:call)
    end
  end
end
