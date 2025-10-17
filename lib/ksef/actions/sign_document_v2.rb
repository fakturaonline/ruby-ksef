# frozen_string_literal: true

require "openssl"
require "nokogiri"
require "securerandom"
require "time"
require "base64"

module KSEF
  module Actions
    # Action for signing XML documents with XAdES-BES signature using Nokogiri
    class SignDocumentV2
      NS_DS = "http://www.w3.org/2000/09/xmldsig#"
      NS_XADES = "http://uri.etsi.org/01903/v1.3.2#"

      # Sign XML document with XAdES signature
      # @param document [String] XML document to sign
      # @param certificate [OpenSSL::X509::Certificate] Certificate for signing
      # @param private_key [OpenSSL::PKey] Private key for signing
      # @return [String] Signed XML document
      def call(document, certificate:, private_key:)
        doc = Nokogiri::XML(document) do |config|
          config.noblanks.strict
        end

        # Generate IDs for signature elements
        signature_id = generate_id
        signed_info_id = generate_id
        signature_value_id = generate_id
        key_info_id = generate_id
        reference_id = generate_id
        object_id = generate_id
        qualifying_properties_id = generate_id
        signed_properties_id = generate_id
        reference_sp_id = generate_id

        # Add Signature element
        signature = create_signature_element(doc, signature_id)
        doc.root.add_child(signature)

        # Create SignedInfo
        signed_info = create_signed_info(
          doc, signed_info_id, reference_id, reference_sp_id,
          signed_properties_id, private_key
        )
        signature.add_child(signed_info)

        # Calculate document digest using exclusive canonicalization
        # (enveloped-signature: document without Signature element)
        doc_for_digest = doc.dup
        doc_for_digest.at_xpath("//ds:Signature", "ds" => NS_DS).remove
        doc_digest = calculate_digest(doc_for_digest.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0))

        # Add document reference to SignedInfo
        ref_doc = signed_info.at_xpath("ds:Reference[@Id='#{reference_id}']", "ds" => NS_DS)
        ref_doc.at_xpath("ds:DigestValue", "ds" => NS_DS).content = doc_digest

        # Add SignatureValue placeholder
        sig_value = create_element(doc, "ds:SignatureValue", NS_DS)
        sig_value["Id"] = signature_value_id
        signature.add_child(sig_value)

        # Add KeyInfo
        key_info = create_key_info(doc, key_info_id, certificate)
        signature.add_child(key_info)

        # Add Object with QualifyingProperties
        obj = create_element(doc, "ds:Object", NS_DS)
        obj["Id"] = object_id
        signature.add_child(obj)

        qualifying_props = create_qualifying_properties(
          doc, qualifying_properties_id, signed_properties_id,
          signature_id, certificate
        )
        obj.add_child(qualifying_props)

        # Calculate SignedProperties digest using exclusive canonicalization
        signed_props = qualifying_props.at_xpath("xades:SignedProperties", "xades" => NS_XADES)
        signed_props_c14n = signed_props.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
        signed_props_digest = calculate_digest(signed_props_c14n)

        # Add SignedProperties reference to SignedInfo
        ref_sp = signed_info.at_xpath("ds:Reference[@Id='#{reference_sp_id}']", "ds" => NS_DS)
        ref_sp.at_xpath("ds:DigestValue", "ds" => NS_DS).content = signed_props_digest

        # Sign SignedInfo using standard canonicalization (not exclusive for SignedInfo itself)
        signed_info_c14n = signed_info.canonicalize
        signature_data = sign_data(signed_info_c14n, private_key)

        # Convert ECDSA DER to raw if needed
        if private_key.is_a?(OpenSSL::PKey::EC)
          signature_data = convert_ecdsa_der_to_raw(signature_data, 32)
        end

        sig_value.content = Base64.strict_encode64(signature_data)

        doc.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
      end

      private

      def create_element(doc, name, namespace)
        prefix = name.split(":").first
        local_name = name.split(":").last
        doc.create_element(local_name, xmlns: namespace)
      end

      def generate_id
        "id-#{SecureRandom.uuid}"
      end

      def calculate_digest(data)
        Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(data))
      end

      def canonicalize_exclusive(node)
        # Use exclusive canonicalization (C14N exclusive)
        xml_string = node.to_xml
        doc = Nokogiri::XML(xml_string) { |config| config.noblanks }
        doc.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      end

      def create_signature_element(doc, id)
        sig = create_element(doc, "ds:Signature", NS_DS)
        sig["Id"] = id
        sig
      end

      def create_signed_info(doc, id, ref_id, ref_sp_id, sp_id, private_key)
        si = create_element(doc, "ds:SignedInfo", NS_DS)
        si["Id"] = id

        # CanonicalizationMethod
        canon = create_element(doc, "ds:CanonicalizationMethod", NS_DS)
        canon["Algorithm"] = "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
        si.add_child(canon)

        # SignatureMethod
        sig_method = create_element(doc, "ds:SignatureMethod", NS_DS)
        sig_method["Algorithm"] = get_signature_algorithm(private_key)
        si.add_child(sig_method)

        # Reference to document
        ref_doc = create_element(doc, "ds:Reference", NS_DS)
        ref_doc["Id"] = ref_id
        ref_doc["URI"] = ""
        si.add_child(ref_doc)

        transforms = create_element(doc, "ds:Transforms", NS_DS)
        ref_doc.add_child(transforms)

        # Transform 1: Enveloped signature
        transform1 = create_element(doc, "ds:Transform", NS_DS)
        transform1["Algorithm"] = "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
        transforms.add_child(transform1)

        # Transform 2: Exclusive canonicalization (this was missing!)
        transform2 = create_element(doc, "ds:Transform", NS_DS)
        transform2["Algorithm"] = "http://www.w3.org/2001/10/xml-exc-c14n#"
        transforms.add_child(transform2)

        digest_method = create_element(doc, "ds:DigestMethod", NS_DS)
        digest_method["Algorithm"] = "http://www.w3.org/2001/04/xmlenc#sha256"
        ref_doc.add_child(digest_method)

        digest_value = create_element(doc, "ds:DigestValue", NS_DS)
        ref_doc.add_child(digest_value)

        # Reference to SignedProperties
        ref_sp = create_element(doc, "ds:Reference", NS_DS)
        ref_sp["Id"] = ref_sp_id
        ref_sp["Type"] = "http://uri.etsi.org/01903#SignedProperties"
        ref_sp["URI"] = "##{sp_id}"
        si.add_child(ref_sp)

        # Add exclusive canonicalization transform for SignedProperties
        transforms_sp = create_element(doc, "ds:Transforms", NS_DS)
        ref_sp.add_child(transforms_sp)

        transform_sp = create_element(doc, "ds:Transform", NS_DS)
        transform_sp["Algorithm"] = "http://www.w3.org/2001/10/xml-exc-c14n#"
        transforms_sp.add_child(transform_sp)

        digest_method_sp = create_element(doc, "ds:DigestMethod", NS_DS)
        digest_method_sp["Algorithm"] = "http://www.w3.org/2001/04/xmlenc#sha256"
        ref_sp.add_child(digest_method_sp)

        digest_value_sp = create_element(doc, "ds:DigestValue", NS_DS)
        ref_sp.add_child(digest_value_sp)

        si
      end

      def create_key_info(doc, id, certificate)
        ki = create_element(doc, "ds:KeyInfo", NS_DS)
        ki["Id"] = id if id

        x509data = create_element(doc, "ds:X509Data", NS_DS)
        ki.add_child(x509data)

        x509cert = create_element(doc, "ds:X509Certificate", NS_DS)
        x509cert.content = Base64.strict_encode64(certificate.to_der).gsub(/\s+/, "")
        x509data.add_child(x509cert)

        ki
      end

      def create_qualifying_properties(doc, qp_id, sp_id, sig_id, certificate)
        qp = create_element(doc, "xades:QualifyingProperties", NS_XADES)
        qp["Id"] = qp_id
        qp["Target"] = "##{sig_id}"

        sp = create_element(doc, "xades:SignedProperties", NS_XADES)
        sp["Id"] = sp_id
        qp.add_child(sp)

        ssp = create_element(doc, "xades:SignedSignatureProperties", NS_XADES)
        sp.add_child(ssp)

        # SigningTime
        signing_time = create_element(doc, "xades:SigningTime", NS_XADES)
        signing_time.content = Time.now.utc.iso8601
        ssp.add_child(signing_time)

        # SigningCertificate
        signing_cert = create_signing_certificate(doc, certificate)
        ssp.add_child(signing_cert)

        qp
      end

      def create_signing_certificate(doc, certificate)
        sc = create_element(doc, "xades:SigningCertificate", NS_XADES)

        cert = create_element(doc, "xades:Cert", NS_XADES)
        sc.add_child(cert)

        cert_digest = create_element(doc, "xades:CertDigest", NS_XADES)
        cert.add_child(cert_digest)

        digest_method = create_element(doc, "ds:DigestMethod", NS_DS)
        digest_method["Algorithm"] = "http://www.w3.org/2001/04/xmlenc#sha256"
        cert_digest.add_child(digest_method)

        fingerprint = calculate_digest(certificate.to_der)
        digest_value = create_element(doc, "ds:DigestValue", NS_DS)
        digest_value.content = fingerprint
        cert_digest.add_child(digest_value)

        issuer_serial = create_element(doc, "xades:IssuerSerial", NS_XADES)
        cert.add_child(issuer_serial)

        issuer_name = create_element(doc, "ds:X509IssuerName", NS_DS)
        issuer_name.content = certificate.issuer.to_s
        issuer_serial.add_child(issuer_name)

        serial_number = create_element(doc, "ds:X509SerialNumber", NS_DS)
        serial_number.content = certificate.serial.to_s
        issuer_serial.add_child(serial_number)

        sc
      end

      def get_signature_algorithm(private_key)
        case private_key
        when OpenSSL::PKey::RSA
          "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"
        when OpenSSL::PKey::EC
          "http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256"
        else
          raise ArgumentError, "Unsupported key type: #{private_key.class}"
        end
      end

      def sign_data(data, private_key)
        digest = OpenSSL::Digest.new("SHA256")
        private_key.sign(digest, data)
      end

      def convert_ecdsa_der_to_raw(der_signature, key_size)
        # Parse DER signature (ASN.1 SEQUENCE of two INTEGERs: r and s)
        asn1 = OpenSSL::ASN1.decode(der_signature)
        r = asn1.value[0].value.to_s(2)
        s = asn1.value[1].value.to_s(2)

        # Pad to key_size
        r = r.rjust(key_size, "\x00")
        s = s.rjust(key_size, "\x00")

        r + s
      end
    end
  end
end
