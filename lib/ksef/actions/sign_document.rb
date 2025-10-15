# frozen_string_literal: true

require 'openssl'
require 'rexml/document'
require 'securerandom'
require 'time'

module KSEF
  module Actions
    # Action for signing XML documents with XAdES signature
    # Based on grafinet/xades-tools logic
    class SignDocument
      # Sign XML document with XAdES signature
      # @param document [String] XML document to sign
      # @param certificate [OpenSSL::X509::Certificate] Certificate for signing
      # @param private_key [OpenSSL::PKey] Private key for signing
      # @return [String] Signed XML document
      def call(document, certificate:, private_key:)
        doc = REXML::Document.new(document)

        ids = {}

        # Calculate digest of the original document
        digest1 = Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(doc.root.to_s))

        # Create Signature element
        signature = create_element(doc, 'ds:Signature', 'http://www.w3.org/2000/09/xmldsig#')
        signature.add_attribute('Id', ids[:signature] = generate_guid)
        doc.root.add_element(signature)

        # Create SignedInfo
        signed_info = create_element(doc, 'ds:SignedInfo', 'http://www.w3.org/2000/09/xmldsig#')
        signed_info.add_attribute('Id', generate_guid)
        signature.add_element(signed_info)

        # CanonicalizationMethod
        canonicalization_method = create_element(doc, 'ds:CanonicalizationMethod', 'http://www.w3.org/2000/09/xmldsig#')
        canonicalization_method.add_attribute('Algorithm', 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315')
        signed_info.add_element(canonicalization_method)

        # SignatureMethod
        signature_method = create_element(doc, 'ds:SignatureMethod', 'http://www.w3.org/2000/09/xmldsig#')
        algorithm = get_signature_algorithm(private_key)
        signature_method.add_attribute('Algorithm', algorithm)
        signed_info.add_element(signature_method)

        # Reference 1 (to document)
        reference1 = create_reference(doc, ids, digest1, '')
        signed_info.add_element(reference1)

        # SignatureValue placeholder
        signature_value = create_element(doc, 'ds:SignatureValue', 'http://www.w3.org/2000/09/xmldsig#')
        signature_value.add_attribute('Id', generate_guid)
        signature.add_element(signature_value)

        # KeyInfo
        key_info = create_key_info(doc, certificate)
        signature.add_element(key_info)

        # Object with QualifyingProperties
        object = create_element(doc, 'ds:Object', 'http://www.w3.org/2000/09/xmldsig#')
        signature.add_element(object)

        qualifying_properties = create_qualifying_properties(doc, ids, certificate)
        object.add_element(qualifying_properties)

        signed_properties = qualifying_properties.elements['xades:SignedProperties']
        ids[:signed_properties] = signed_properties.attributes['Id']

        # Reference 2 (to SignedProperties)
        signed_properties_digest = Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(canonicalize(signed_properties)))
        reference2 = create_signed_properties_reference(doc, ids, signed_properties_digest)
        signed_info.add_element(reference2)

        # Sign SignedInfo
        signed_info_c14n = canonicalize(signed_info)
        signature_data = sign_data(signed_info_c14n, private_key)

        # Convert ECDSA DER to raw if needed
        if private_key.is_a?(OpenSSL::PKey::EC)
          converter = ConvertEcdsaDerToRaw.new
          signature_data = converter.call(signature_data, key_size: 32)
        end

        signature_value.text = Base64.strict_encode64(signature_data)

        doc.to_s
      end

      private

      def create_element(doc, name, namespace)
        REXML::Element.new(name).tap do |el|
          el.add_namespace(namespace.split(':').first, namespace)
        end
      end

      def generate_guid
        "id-#{SecureRandom.uuid}"
      end

      def get_signature_algorithm(private_key)
        case private_key
        when OpenSSL::PKey::RSA
          'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'
        when OpenSSL::PKey::EC
          'http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256'
        else
          raise ArgumentError, "Unsupported key type: #{private_key.class}"
        end
      end

      def create_reference(doc, ids, digest, uri)
        reference = create_element(doc, 'ds:Reference', 'http://www.w3.org/2000/09/xmldsig#')
        reference.add_attribute('Id', ids[:reference1] = generate_guid)
        reference.add_attribute('URI', uri)

        transforms = create_element(doc, 'ds:Transforms', 'http://www.w3.org/2000/09/xmldsig#')
        transform = create_element(doc, 'ds:Transform', 'http://www.w3.org/2000/09/xmldsig#')
        transform.add_attribute('Algorithm', 'http://www.w3.org/2000/09/xmldsig#enveloped-signature')
        transforms.add_element(transform)
        reference.add_element(transforms)

        digest_method = create_element(doc, 'ds:DigestMethod', 'http://www.w3.org/2000/09/xmldsig#')
        digest_method.add_attribute('Algorithm', 'http://www.w3.org/2001/04/xmlenc#sha256')
        reference.add_element(digest_method)

        digest_value = create_element(doc, 'ds:DigestValue', 'http://www.w3.org/2000/09/xmldsig#')
        digest_value.text = digest
        reference.add_element(digest_value)

        reference
      end

      def create_signed_properties_reference(doc, ids, digest)
        reference = create_element(doc, 'ds:Reference', 'http://www.w3.org/2000/09/xmldsig#')
        reference.add_attribute('Id', generate_guid)
        reference.add_attribute('Type', 'http://uri.etsi.org/01903#SignedProperties')
        reference.add_attribute('URI', "##{ids[:signed_properties]}")

        digest_method = create_element(doc, 'ds:DigestMethod', 'http://www.w3.org/2000/09/xmldsig#')
        digest_method.add_attribute('Algorithm', 'http://www.w3.org/2001/04/xmlenc#sha256')
        reference.add_element(digest_method)

        digest_value = create_element(doc, 'ds:DigestValue', 'http://www.w3.org/2000/09/xmldsig#')
        digest_value.text = digest
        reference.add_element(digest_value)

        reference
      end

      def create_key_info(doc, certificate)
        key_info = create_element(doc, 'ds:KeyInfo', 'http://www.w3.org/2000/09/xmldsig#')
        x509data = create_element(doc, 'ds:X509Data', 'http://www.w3.org/2000/09/xmldsig#')
        x509certificate = create_element(doc, 'ds:X509Certificate', 'http://www.w3.org/2000/09/xmldsig#')
        x509certificate.text = Base64.strict_encode64(certificate.to_der).gsub(/\s+/, '')
        x509data.add_element(x509certificate)
        key_info.add_element(x509data)
        key_info
      end

      def create_qualifying_properties(doc, ids, certificate)
        qualifying_properties = create_element(doc, 'xades:QualifyingProperties', 'http://uri.etsi.org/01903/v1.3.2#')
        qualifying_properties.add_attribute('Id', generate_guid)
        qualifying_properties.add_attribute('Target', "##{ids[:signature]}")

        signed_properties = create_element(doc, 'xades:SignedProperties', 'http://uri.etsi.org/01903/v1.3.2#')
        signed_properties.add_attribute('Id', generate_guid)
        qualifying_properties.add_element(signed_properties)

        signed_signature_properties = create_element(doc, 'xades:SignedSignatureProperties', 'http://uri.etsi.org/01903/v1.3.2#')
        signed_properties.add_element(signed_signature_properties)

        # SigningTime
        signing_time = create_element(doc, 'xades:SigningTime', 'http://uri.etsi.org/01903/v1.3.2#')
        signing_time.text = Time.now.utc.iso8601
        signed_signature_properties.add_element(signing_time)

        # SigningCertificate
        signing_certificate = create_signing_certificate(doc, certificate)
        signed_signature_properties.add_element(signing_certificate)

        qualifying_properties
      end

      def create_signing_certificate(doc, certificate)
        signing_certificate = create_element(doc, 'xades:SigningCertificate', 'http://uri.etsi.org/01903/v1.3.2#')

        cert = create_element(doc, 'xades:Cert', 'http://uri.etsi.org/01903/v1.3.2#')
        signing_certificate.add_element(cert)

        cert_digest = create_element(doc, 'xades:CertDigest', 'http://uri.etsi.org/01903/v1.3.2#')
        cert.add_element(cert_digest)

        digest_method = create_element(doc, 'ds:DigestMethod', 'http://www.w3.org/2000/09/xmldsig#')
        digest_method.add_attribute('Algorithm', 'http://www.w3.org/2001/04/xmlenc#sha256')
        cert_digest.add_element(digest_method)

        fingerprint = Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(certificate.to_der))
        digest_value = create_element(doc, 'ds:DigestValue', 'http://www.w3.org/2000/09/xmldsig#')
        digest_value.text = fingerprint
        cert_digest.add_element(digest_value)

        issuer_serial = create_element(doc, 'xades:IssuerSerial', 'http://uri.etsi.org/01903/v1.3.2#')
        cert.add_element(issuer_serial)

        issuer_name = create_element(doc, 'ds:X509IssuerName', 'http://www.w3.org/2000/09/xmldsig#')
        issuer_name.text = certificate.issuer.to_s
        issuer_serial.add_element(issuer_name)

        serial_number = create_element(doc, 'ds:X509SerialNumber', 'http://www.w3.org/2000/09/xmldsig#')
        serial_number.text = certificate.serial.to_s
        issuer_serial.add_element(serial_number)

        signing_certificate
      end

      def canonicalize(element)
        # Simplified C14N - Ruby REXML doesn't have built-in C14N
        # This is a basic implementation that should work for most cases
        element.to_s
      end

      def sign_data(data, private_key)
        digest = OpenSSL::Digest::SHA256.new
        private_key.sign(digest, data)
      end
    end
  end
end
