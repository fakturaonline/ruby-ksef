# frozen_string_literal: true

require "rexml/document"

module KSEF
  module InvoiceSchema
    # Module for XML serialization
    module XMLSerializable
      # Convert to XML string
      # @return [String] XML representation
      def to_xml
        to_rexml.to_s
      end

      # Convert to REXML::Document
      # @return [REXML::Document] REXML document
      def to_rexml
        raise NotImplementedError, "#{self.class} must implement #to_rexml"
      end

      protected

      # Helper to create element with text content
      # @param _doc [REXML::Document] Document (unused, kept for API compatibility)
      # @param name [String] Element name
      # @param value [Object, nil] Optional value
      # @return [REXML::Element] Created element
      def create_element(_doc, name, value = nil)
        element = REXML::Element.new(name)
        element.text = value.to_s if value
        element
      end

      # Helper to add element with text if value is present
      # @param parent [REXML::Element] Parent element
      # @param name [String] Element name
      # @param value [Object, nil] Optional value
      # @return [REXML::Element, nil] Created element or nil
      def add_element_if_present(parent, name, value)
        return nil if value.nil?

        element = REXML::Element.new(name)
        element.text = value.to_s
        parent.add_element(element)
        element
      end

      # Helper to add child REXML document as element
      # @param parent [REXML::Element] Parent element
      # @param child_serializable [XMLSerializable] Child object
      # @return [void]
      def add_child_element(parent, child_serializable)
        return if child_serializable.nil?

        child_doc = child_serializable.to_rexml
        parent.add_element(child_doc.root)
      end

      # Helper to add array of child elements
      # @param parent [REXML::Element] Parent element
      # @param children [Array<XMLSerializable>] Array of child objects
      # @return [void]
      def add_child_elements(parent, children)
        return if children.nil? || children.empty?

        children.each do |child|
          add_child_element(parent, child)
        end
      end
    end
  end
end
