# frozen_string_literal: true

module KSEF
  module Actions
    # Action for converting DER format to PEM format
    class ConvertDerToPem
      # Convert DER to PEM format
      # @param der [String] DER-encoded data
      # @param name [String] PEM block name (e.g., "CERTIFICATE", "PRIVATE KEY")
      # @return [String] PEM-encoded data
      def call(der, name: "CERTIFICATE")
        base64_der = Base64.strict_encode64(der)
        pem_lines = base64_der.scan(/.{1,64}/)

        "-----BEGIN #{name}-----\n" +
          pem_lines.join("\n") + "\n" \
                                 "-----END #{name}-----\n"
      end
    end
  end
end
