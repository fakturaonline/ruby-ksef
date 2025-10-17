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
          # Note: Using verifyCertificateChain=false for self-signed test certificates
          response = @http_client.request(
            method: :post,
            path: "auth/xades-signature",
            body: xml,
            headers: {
              "Content-Type" => "application/xml",
              "Accept" => "application/json"
            },
            params: {
              "verifyCertificateChain" => "false"
            }
          )

          response.json
        end

        private

        def build_xades_xml(challenge:, certificate:, private_key:)
          # Create XML document for KSeF API v2
          builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            xml.AuthTokenRequest(
              "xmlns" => "http://ksef.mf.gov.pl/auth/token/2.0"
            ) do
              xml.Challenge challenge
              xml.ContextIdentifier do
                xml.Nip @identifier.value
              end
              xml.SubjectIdentifierType "certificateSubject"
            end
          end

          # Sign XML
          sign_xml(builder.to_xml, private_key, certificate)
        end

        def sign_xml(xml, private_key, certificate)
          # Use SignDocumentV2 action for proper XAdES signature with Nokogiri
          Actions::SignDocumentV2.new.call(xml, certificate: certificate, private_key: private_key)
        end
      end
    end
  end
end
