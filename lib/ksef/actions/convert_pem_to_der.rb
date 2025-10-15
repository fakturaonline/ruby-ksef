# frozen_string_literal: true

module KSEF
  module Actions
    # Action for converting PEM format to DER format
    class ConvertPemToDer
      # Convert PEM to DER format
      # @param pem [String] PEM-encoded data
      # @return [String] DER-encoded data
      def call(pem)
        # Remove PEM headers, footers and whitespace
        der_string = pem.gsub(/-+BEGIN [^-]+-+|-+END [^-]+-+|\s+/, "")
        Base64.decode64(der_string)
      end
    end
  end
end
