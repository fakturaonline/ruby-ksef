# frozen_string_literal: true

require "nokogiri"
require "time"
require "date"
require "bigdecimal"

module KSEF
  module InvoiceSchema
    # Parser module for XML deserialization
    module Parser
      # Parse XML string to object
      # @param xml [String] XML string
      # @return [Object] Parsed object
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        doc.remove_namespaces! # Simplify parsing
        from_nokogiri(doc)
      end

      # Parse from Nokogiri document
      # @param doc [Nokogiri::XML::Document, Nokogiri::XML::Element] Nokogiri document or element
      # @return [Object] Parsed object
      def from_nokogiri(doc)
        raise NotImplementedError, "#{self.class} must implement #from_nokogiri"
      end

      protected

      # Helper to get text content from element
      # @param element [Nokogiri::XML::Element] Element
      # @param xpath [String] XPath query
      # @return [String, nil] Text content or nil
      def text_at(element, xpath)
        node = element.at_xpath(xpath)
        node&.text&.strip
      end

      # Helper to get date from element
      # @param element [Nokogiri::XML::Element] Element
      # @param xpath [String] XPath query
      # @return [Date, nil] Date or nil
      def date_at(element, xpath)
        text = text_at(element, xpath)
        text ? Date.parse(text) : nil
      end

      # Helper to get time from element
      # @param element [Nokogiri::XML::Element] Element
      # @param xpath [String] XPath query
      # @return [Time, nil] Time or nil
      def time_at(element, xpath)
        text = text_at(element, xpath)
        text ? Time.parse(text) : nil
      end

      # Helper to get decimal from element
      # @param element [Nokogiri::XML::Element] Element
      # @param xpath [String] XPath query
      # @return [BigDecimal, nil] Decimal or nil
      def decimal_at(element, xpath)
        text = text_at(element, xpath)
        text ? BigDecimal(text) : nil
      end

      # Helper to get integer from element
      # @param element [Nokogiri::XML::Element] Element
      # @param xpath [String] XPath query
      # @return [Integer, nil] Integer or nil
      def integer_at(element, xpath)
        text = text_at(element, xpath)
        text&.to_i
      end

      # Helper to parse array of child elements
      # @param element [Nokogiri::XML::Element] Parent element
      # @param xpath [String] XPath query
      # @param klass [Class] Class to parse each element with
      # @return [Array] Array of parsed objects
      def array_at(element, xpath, klass)
        element.xpath(xpath).map do |node|
          klass.from_nokogiri(node)
        end
      end

      # Helper to parse optional child element
      # @param element [Nokogiri::XML::Element] Parent element
      # @param xpath [String] XPath query
      # @param klass [Class] Class to parse element with
      # @return [Object, nil] Parsed object or nil
      def object_at(element, xpath, klass)
        node = element.at_xpath(xpath)
        node ? klass.from_nokogiri(node) : nil
      end
    end
  end
end
