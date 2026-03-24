# frozen_string_literal: true

require "spec_helper"
require "base64"
require "openssl"

# Integration test for sending invoices to KSeF
# Uses real KSeF test environment with VCR for recording HTTP interactions
RSpec.describe "Invoice Sending Integration" do
  let(:test_nip) { "7980332920" }
  let(:test_ksef_token) do
    # Valid test token - VCR records HTTP interactions on first run
    # After that, test uses recorded cassettes (works offline)
    # Token is automatically filtered in cassettes as <KSEF_TOKEN>
    #
    # Latest recorded: 2026-01-19 with new API URLs (https://api-test.ksef.mf.gov.pl/v2)
    "20260119-EC-358EFDB000-459EC03E91-53|nip-7980332920|4f0a7de61fa84925a9b5997cdf410549f04c0022b21141069b7d93e06b29b203"
  end

  describe "sending a valid FA(3) invoice" do
    xit "successfully sends an invoice using high-level API", vcr: {
      # PENDING: VCR cassette needs to be re-recorded with actual FA(3) invoice
      # Missing cassette for: POST https://api-test.ksef.mf.gov.pl/v2/auth/token/refresh
      cassette_name: "invoice_sending/successful_fa3_highlevel",
      record: :once,
      match_requests_on: %i[method uri] # Don't match on body - encrypted tokens contain timestamps
    } do
      # Build client within VCR context so authentication is recorded/replayed
      nip = test_nip
      token = test_ksef_token
      client = KSEF.build do
        mode :test
        identifier nip
        ksef_token token
      end
      # 1. Create a valid FA(3) invoice
      invoice = create_test_invoice

      # 2. Generate XML
      xml = invoice.to_xml
      expect(xml).to be_a(String)
      expect(xml).to include("<KodFormularza")

      puts "\n#{"=" * 80}"
      puts "GENERATED INVOICE XML (size: #{xml.bytesize} bytes)"
      puts "=" * 80
      puts "#{xml[0..500]}..." if xml.length > 500
      puts "=" * 80

      # 3. Send invoice using high-level API
      # (handles encryption, sending, and session closing automatically)
      response = client.send_invoice_online(xml)

      # Check response structure
      expect(response).to have_key("referenceNumber")
      expect(response).to have_key("sessionReferenceNumber")
      expect(response).to have_key("sessionClosed")
      expect(response["sessionClosed"]).to be true

      invoice_reference = response["referenceNumber"]
      session_reference = response["sessionReferenceNumber"]

      puts "\n✅ Invoice sent and session closed automatically!"
      puts "  Invoice Reference: #{invoice_reference}"
      puts "  Session Reference: #{session_reference}"
      puts "  Session closed: #{response["sessionClosed"]}"

      # 7. Wait a bit for processing (KSeF needs time to process)
      puts "\n⏳ Waiting for KSeF to process invoice..."
      sleep 2

      # 8. Query for recent invoices to verify it's being processed
      puts "\n🔍 Querying recent invoices in KSeF system..."
      begin
        # Query invoices from today
        query_result = client.invoices.query_metadata(
          filters: {
            subjectBy: {
              issuedByName: { type: "onip", identifier: test_nip }
            },
            invoicingDate: {
              from: Date.today.to_s,
              to: Date.today.to_s
            }
          },
          page_size: 10
        )

        invoice_count = query_result.dig("invoices", "invoiceMetadata")&.length || 0
        puts "  ✓ Found #{invoice_count} invoice(s) from today"

        if invoice_count.positive?
          puts "  ✓ Invoice is being processed by KSeF!"
        else
          puts "  ℹ Invoice may still be processing (not yet in query results)"
        end
      rescue StandardError => e
        puts "  ⚠ Could not query invoices: #{e.message}"
        puts "  (This is normal - invoice may need more time to process)"
      end

      # Verify basic response structure
      expect(invoice_reference).to be_a(String)
      expect(invoice_reference).not_to be_empty
      expect(session_reference).to be_a(String)
      expect(session_reference).not_to be_empty

      puts "\n✅ Integration test PASSED!"
      puts "━" * 80
      puts "SUMMARY:"
      puts "  • Invoice Reference: #{invoice_reference}"
      puts "  • Session Reference: #{session_reference}"
      puts "  • Session closed successfully"
      puts "  • Invoice should now be visible in KSeF system"
      puts "━" * 80
    end
  end

  # Helper methods for creating test invoices

  def create_test_invoice
    # Seller (Podmiot1)
    prodejce_dane = KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
      nip: test_nip,
      nazwa: "Test Firma s.r.o."
    )

    prodejce_adres = KSEF::InvoiceSchema::DTOs::Adres.new(
      kod_kraju: "PL",
      adres_l1: "Testowa 1",
      adres_l2: "00-001 Warszawa"
    )

    prodejce = KSEF::InvoiceSchema::DTOs::Podmiot1.new(
      dane_identyfikacyjne: prodejce_dane,
      adres: prodejce_adres
    )

    # Buyer (Podmiot2)
    kupujici_dane = KSEF::InvoiceSchema::DTOs::DaneIdentyfikacyjne.new(
      nip: "1234567890",
      nazwa: "Test Klient Sp. z o.o."
    )

    kupujici_adres = KSEF::InvoiceSchema::DTOs::Adres.new(
      kod_kraju: "PL",
      adres_l1: "Testowa 5",
      adres_l2: "30-001 Kraków"
    )

    kupujici = KSEF::InvoiceSchema::DTOs::Podmiot2.new(
      dane_identyfikacyjne: kupujici_dane,
      adres: kupujici_adres,
      jst: 2,  # 1=ano, 2=ne - jednotka podřízená JST
      gv: 2    # 1=ano, 2=ne - člen skupiny VAT
    )

    # Invoice items
    polozky = [
      KSEF::InvoiceSchema::DTOs::FaWiersz.new(
        nr_wiersza: 1,
        p_7: "Testovací služba",
        p_8a: "ks",
        p_8b: 1,
        p_9a: 100.00,   # Cena jednotková netto
        p_9b: 100.00,   # Hodnota netto
        p_11: 100.00,   # FA(3): P_11 = hodnota netto (ne stawka!)
        p_12: "23"      # FA(3): P_12 = stawka DPH jako string enum
      )
    ]

    # Main invoice part (Fa)
    fa = KSEF::InvoiceSchema::Fa.new(
      kod_waluty: KSEF::InvoiceSchema::ValueObjects::KodWaluty.new("PLN"),
      p_1: Date.today,
      p_2: "TEST/#{Time.now.to_i}/001",
      p_6: Date.today, # DUZP - datum zdanitelného plnění (POVINNÉ pro FA(3))
      p_15: 123.00,
      fa_wiersz: polozky,
      p_13_1: 100.00,  # Základ daně 23%
      p_14_1: 23.00    # DPH 23%
    )

    # Header (Naglowek)
    naglowek = KSEF::InvoiceSchema::Naglowek.new(
      system_info: "Ruby KSEF Client Integration Test"
    )

    # Complete invoice
    KSEF::InvoiceSchema::Faktura.new(
      naglowek: naglowek,
      podmiot1: prodejce,
      podmiot2: kupujici,
      fa: fa
    )
  end
end
