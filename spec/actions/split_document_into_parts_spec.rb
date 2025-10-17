# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::SplitDocumentIntoParts do
  subject(:action) { described_class.new }

  describe "#call" do
    context "with document smaller than part size" do
      it "returns single part" do
        document = "Small document"
        result = action.call(document, part_size: 1000)

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first).to eq(document)
      end
    end

    context "with document exactly matching part size" do
      it "returns single part" do
        document = "A" * 100
        result = action.call(document, part_size: 100)

        expect(result.length).to eq(1)
        expect(result.first).to eq(document)
      end
    end

    context "with document requiring multiple parts" do
      it "splits into multiple parts" do
        document = "A" * 250
        result = action.call(document, part_size: 100)

        expect(result).to be_an(Array)
        expect(result.length).to eq(3)

        # All parts should be roughly equal size
        result.each do |part|
          expect(part.bytesize).to be_between(80, 90)
        end

        # Verify concatenation equals original
        expect(result.join).to eq(document)
      end

      it "distributes bytes evenly across parts" do
        document = "B" * 1000
        result = action.call(document, part_size: 300)

        # Should create 4 parts of ~250 bytes each (1000/4)
        expect(result.length).to eq(4)

        result.each do |part|
          expect(part.bytesize).to be_between(240, 260)
        end

        expect(result.join).to eq(document)
      end
    end

    context "with binary data" do
      it "handles binary data correctly" do
        document = (0..255).to_a.pack("C*") * 4 # 1024 bytes
        result = action.call(document, part_size: 300)

        expect(result.length).to eq(4)
        expect(result.map(&:bytesize).sum).to eq(document.bytesize)
        expect(result.join).to eq(document)
      end
    end

    context "with UTF-8 text" do
      it "handles UTF-8 correctly" do
        document = "Test Łódź Kraków " * 20 # Polish characters
        result = action.call(document, part_size: 100)

        expect(result.length).to be >= 2

        # Parts may split UTF-8 sequences, but concatenation should work
        expect(result.join).to eq(document)
      end
    end

    context "with very small part size" do
      it "creates many small parts" do
        document = "Test document for splitting"
        result = action.call(document, part_size: 5)

        expect(result.length).to be >= 5
        expect(result.join).to eq(document)
      end
    end

    context "with very large part size" do
      it "returns entire document in one part" do
        document = "Test"
        result = action.call(document, part_size: 1_000_000)

        expect(result.length).to eq(1)
        expect(result.first).to eq(document)
      end
    end

    context "with empty document" do
      it "returns empty array" do
        document = ""
        result = action.call(document, part_size: 100)

        expect(result).to be_empty
      end
    end

    context "part size calculation" do
      it "calculates optimal part size correctly" do
        document = "X" * 1000
        result = action.call(document, part_size: 300)

        # 1000 / 300 = 3.33, ceil = 4 parts
        expect(result.length).to eq(4)

        # 1000 / 4 = 250 bytes per part
        result.each do |part|
          expect(part.bytesize).to eq(250)
        end
      end

      it "handles edge case with exact division" do
        document = "Y" * 900
        result = action.call(document, part_size: 300)

        # 900 / 300 = 3 exactly
        expect(result.length).to eq(3)

        result.each do |part|
          expect(part.bytesize).to eq(300)
        end
      end
    end

    context "with real XML document" do
      let(:xml_document) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <Document>
            <Header>
              <ID>12345</ID>
              <Timestamp>#{Time.now.iso8601}</Timestamp>
            </Header>
            <Body>
              #{'<Item>Content</Item>' * 100}
            </Body>
          </Document>
        XML
      end

      it "splits large XML into parts" do
        result = action.call(xml_document, part_size: 500)

        expect(result.length).to be > 1
        expect(result.join).to eq(xml_document)

        # Note: Parts may not be valid XML individually,
        # but concatenation should restore original
        concatenated = result.join
        doc = Nokogiri::XML(concatenated)
        expect(doc.errors).to be_empty
      end
    end
  end
end
