# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Resources::Sessions do
  let(:http_client) { instance_double(KSEF::HttpClient) }
  subject(:sessions) { described_class.new(http_client) }

  describe "#send_online" do
    it "calls SendOnlineHandler with reference number and params" do
      params = { invoice: "<xml>data</xml>" }
      handler = instance_double(KSEF::Requests::Sessions::SendOnlineHandler)
      allow(KSEF::Requests::Sessions::SendOnlineHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", params).and_return({ ksef_number: "123" })

      result = sessions.send_online("REF123", params)

      expect(result).to eq({ ksef_number: "123" })
      expect(handler).to have_received(:call).with("REF123", params)
    end
  end

  describe "#send_batch" do
    it "calls SendBatchHandler with params" do
      params = { invoices: [{ invoice: "<xml>1</xml>" }] }
      handler = instance_double(KSEF::Requests::Sessions::SendBatchHandler)
      allow(KSEF::Requests::Sessions::SendBatchHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with(params).and_return({ reference_number: "BATCH123" })

      result = sessions.send_batch(params)

      expect(result).to eq({ reference_number: "BATCH123" })
      expect(handler).to have_received(:call).with(params)
    end
  end

  describe "#status" do
    it "calls StatusHandler with reference number" do
      handler = instance_double(KSEF::Requests::Sessions::StatusHandler)
      allow(KSEF::Requests::Sessions::StatusHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "active" })

      result = sessions.status("REF123")

      expect(result).to eq({ status: "active" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#terminate" do
    it "calls TerminateHandler with reference number" do
      handler = instance_double(KSEF::Requests::Sessions::TerminateHandler)
      allow(KSEF::Requests::Sessions::TerminateHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "terminated" })

      result = sessions.terminate("REF123")

      expect(result).to eq({ status: "terminated" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#upo_by_ksef_number" do
    it "calls UpoByKsefNumberHandler" do
      handler = instance_double(KSEF::Requests::Sessions::UpoByKsefNumberHandler)
      allow(KSEF::Requests::Sessions::UpoByKsefNumberHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", "KSEF456").and_return({ upo: "<xml>upo</xml>" })

      result = sessions.upo_by_ksef_number("REF123", "KSEF456")

      expect(result).to eq({ upo: "<xml>upo</xml>" })
      expect(handler).to have_received(:call).with("REF123", "KSEF456")
    end
  end

  describe "#upo_by_invoice_reference" do
    it "calls UpoByInvoiceReferenceHandler" do
      handler = instance_double(KSEF::Requests::Sessions::UpoByInvoiceReferenceHandler)
      allow(KSEF::Requests::Sessions::UpoByInvoiceReferenceHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", "INV456").and_return({ upo: "<xml>upo</xml>" })

      result = sessions.upo_by_invoice_reference("REF123", "INV456")

      expect(result).to eq({ upo: "<xml>upo</xml>" })
      expect(handler).to have_received(:call).with("REF123", "INV456")
    end
  end

  describe "#upo" do
    it "calls UpoHandler" do
      handler = instance_double(KSEF::Requests::Sessions::UpoHandler)
      allow(KSEF::Requests::Sessions::UpoHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", "UPO789").and_return({ upo: "<xml>upo</xml>" })

      result = sessions.upo("REF123", "UPO789")

      expect(result).to eq({ upo: "<xml>upo</xml>" })
      expect(handler).to have_received(:call).with("REF123", "UPO789")
    end
  end

  describe "#close_online" do
    it "calls CloseOnlineHandler" do
      handler = instance_double(KSEF::Requests::Sessions::CloseOnlineHandler)
      allow(KSEF::Requests::Sessions::CloseOnlineHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "closed" })

      result = sessions.close_online("REF123")

      expect(result).to eq({ status: "closed" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#close_batch" do
    it "calls CloseBatchHandler" do
      handler = instance_double(KSEF::Requests::Sessions::CloseBatchHandler)
      allow(KSEF::Requests::Sessions::CloseBatchHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123").and_return({ status: "closed" })

      result = sessions.close_batch("REF123")

      expect(result).to eq({ status: "closed" })
      expect(handler).to have_received(:call).with("REF123")
    end
  end

  describe "#invoices" do
    it "calls InvoicesHandler without params" do
      handler = instance_double(KSEF::Requests::Sessions::InvoicesHandler)
      allow(KSEF::Requests::Sessions::InvoicesHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", {}).and_return({ invoices: [] })

      result = sessions.invoices("REF123")

      expect(result).to eq({ invoices: [] })
      expect(handler).to have_received(:call).with("REF123", {})
    end

    it "calls InvoicesHandler with params" do
      params = { page_size: 10 }
      handler = instance_double(KSEF::Requests::Sessions::InvoicesHandler)
      allow(KSEF::Requests::Sessions::InvoicesHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", params).and_return({ invoices: [] })

      result = sessions.invoices("REF123", params)

      expect(result).to eq({ invoices: [] })
      expect(handler).to have_received(:call).with("REF123", params)
    end
  end

  describe "#invoice" do
    it "calls InvoiceHandler" do
      handler = instance_double(KSEF::Requests::Sessions::InvoiceHandler)
      allow(KSEF::Requests::Sessions::InvoiceHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", "INV456").and_return({ invoice: "data" })

      result = sessions.invoice("REF123", "INV456")

      expect(result).to eq({ invoice: "data" })
      expect(handler).to have_received(:call).with("REF123", "INV456")
    end
  end

  describe "#failed_invoices" do
    it "calls FailedInvoicesHandler without params" do
      handler = instance_double(KSEF::Requests::Sessions::FailedInvoicesHandler)
      allow(KSEF::Requests::Sessions::FailedInvoicesHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", {}).and_return({ failed_invoices: [] })

      result = sessions.failed_invoices("REF123")

      expect(result).to eq({ failed_invoices: [] })
      expect(handler).to have_received(:call).with("REF123", {})
    end

    it "calls FailedInvoicesHandler with params" do
      params = { page_size: 5 }
      handler = instance_double(KSEF::Requests::Sessions::FailedInvoicesHandler)
      allow(KSEF::Requests::Sessions::FailedInvoicesHandler).to receive(:new).with(http_client).and_return(handler)
      allow(handler).to receive(:call).with("REF123", params).and_return({ failed_invoices: [] })

      result = sessions.failed_invoices("REF123", params)

      expect(result).to eq({ failed_invoices: [] })
      expect(handler).to have_received(:call).with("REF123", params)
    end
  end
end
