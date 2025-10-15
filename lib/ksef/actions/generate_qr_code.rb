# frozen_string_literal: true

require "rqrcode"

module KSEF
  module Actions
    # Action for generating QR codes for invoices
    class GenerateQrCode
      def initialize(nip:, invoice_date:, ksef_number: nil)
        @nip = nip
        @invoice_date = invoice_date
        @ksef_number = ksef_number
      end

      def call
        qr_data = build_qr_data
        qrcode = RQRCode::QRCode.new(qr_data)

        {
          data: qr_data,
          svg: qrcode.as_svg(module_size: 6),
          png: qrcode.as_png(size: 300)
        }
      end

      private

      def build_qr_data
        if @ksef_number
          # Online invoice QR code
          "https://ksef.mf.gov.pl/web/invoice/#{@ksef_number}"
        else
          # Offline invoice QR code
          "NIP:#{@nip}|DATA:#{@invoice_date.strftime("%Y-%m-%d")}"
        end
      end
    end
  end
end
