# frozen_string_literal: true

module KSEF
  module Requests
    module Auth
      # Handler for XAdES signature authentication (certificate-based)
      class XadesSignatureHandler
        def initialize(http_client, certificate_path, identifier)
          @http_client = http_client
          @certificate_path = certificate_path
          @identifier = identifier
        end

        def call(challenge_response)
          # Load certificate
          pkcs12 = OpenSSL::PKCS12.new(
            File.read(@certificate_path.path),
            @certificate_path.passphrase
          )

          # Build XAdES XML
          xml = build_xades_xml(
            challenge: challenge_response["challenge"],
            certificate: pkcs12.certificate,
            private_key: pkcs12.key
          )

          # Send authentication request
          response = @http_client.post(
            "auth/xades-signature",
            body: xml,
            headers: { "Content-Type" => "application/xml" }
          )

          response.json
        end

        private

        def build_xades_xml(challenge:, certificate:, private_key:)
          # Create XML document
          builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml["tns"].AuthRequest(
              "xmlns:tns" => "http://ksef.mf.gov.pl/schema/gtw/svc/online/auth/request/2021/10/01/0001",
              "xmlns:ds" => "http://www.w3.org/2000/09/xmldsig#"
            ) do
              xml["tns"].Challenge challenge
              xml["tns"].ContextIdentifierGroup do
                xml["tns"].IdentifierGroup do
                  xml["tns"].Nip @identifier.value
                end
              end
              xml["tns"].SubjectIdentifierType "certificateSubject"

              # Add signature placeholder
              xml["ds"].Signature do
                # TODO: Implement full XMLDSig signature
                # For now, this is a placeholder
              end
            end
          end

          # Sign XML
          sign_xml(builder.to_xml, private_key, certificate)
        end

        def sign_xml(xml, private_key, certificate)
          # TODO: Implement proper XMLDSig signature
          # This requires xmldsig gem or manual implementation
          # For now, return unsigned XML as placeholder
          xml
        end
      end
    end
  end
end
