# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Actions::ZipDocuments do
  subject(:action) { described_class.new }

  describe "#call" do
    context "with single document" do
      it "creates zip archive" do
        documents = ["Test document content"]
        result = action.call(documents)

        expect(result).to be_a(String)
        expect(result).not_to be_empty

        # Verify it's valid ZIP
        expect(result[0..1]).to eq("PK") # ZIP magic number
      end

      it "can be extracted" do
        documents = ["Test document content"]
        result = action.call(documents)

        # Write to temp file and verify
        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            expect(zip_file.entries.length).to eq(1)

            entry = zip_file.entries.first
            expect(entry.name).to match(/xml_[a-f0-9]{16}\.xml/)

            content = zip_file.read(entry)
            expect(content).to eq("Test document content")
          end
        end
      end
    end

    context "with multiple documents" do
      it "creates zip with multiple files" do
        documents = [
          "First document",
          "Second document",
          "Third document"
        ]
        result = action.call(documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            expect(zip_file.entries.length).to eq(3)

            contents = zip_file.entries.map { |e| zip_file.read(e) }
            expect(contents).to match_array(documents)
          end
        end
      end

      it "generates unique filenames for each document" do
        documents = ["Doc 1", "Doc 2", "Doc 3"]
        result = action.call(documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            filenames = zip_file.entries.map(&:name)

            # All filenames should be unique
            expect(filenames.uniq.length).to eq(filenames.length)

            # All filenames should match pattern
            filenames.each do |filename|
              expect(filename).to match(/xml_[a-f0-9]{16}\.xml/)
            end
          end
        end
      end
    end

    context "with XML documents" do
      let(:xml_documents) do
        [
          '<?xml version="1.0"?><Doc><ID>1</ID></Doc>',
          '<?xml version="1.0"?><Doc><ID>2</ID></Doc>',
          '<?xml version="1.0"?><Doc><ID>3</ID></Doc>'
        ]
      end

      it "preserves XML content" do
        result = action.call(xml_documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            contents = zip_file.entries.map { |e| zip_file.read(e) }

            contents.each do |content|
              doc = Nokogiri::XML(content)
              expect(doc.errors).to be_empty
              expect(doc.at_xpath("//ID")).not_to be_nil
            end

            expect(contents).to match_array(xml_documents)
          end
        end
      end
    end

    context "with binary data" do
      it "handles binary content correctly" do
        documents = [
          (0..255).to_a.pack("C*"),
          (255.downto(0)).to_a.pack("C*")
        ]
        result = action.call(documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.binmode
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            contents = zip_file.entries.map { |e| zip_file.read(e) }

            expect(contents[0]).to eq(documents[0])
            expect(contents[1]).to eq(documents[1])
          end
        end
      end
    end

    context "with UTF-8 content" do
      it "preserves UTF-8 encoding" do
        documents = [
          "Zażółć gęślą jaźń", # Polish
          "Příliš žluťoučký kůň", # Czech
          "Test łódź Kraków" # Mixed
        ]
        result = action.call(documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            contents = zip_file.entries.map { |e| zip_file.read(e).force_encoding("UTF-8") }

            contents.each do |content|
              expect(content.encoding).to eq(Encoding::UTF_8)
              expect(content.valid_encoding?).to be true
            end

            expect(contents).to match_array(documents)
          end
        end
      end
    end

    context "with large documents" do
      it "handles large documents" do
        documents = [
          "A" * 1_000_000, # 1 MB
          "B" * 1_000_000,
          "C" * 1_000_000
        ]
        result = action.call(documents)

        expect(result.bytesize).to be < 3_000_000 # Should be compressed

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            expect(zip_file.entries.length).to eq(3)

            zip_file.entries.each_with_index do |entry, index|
              content = zip_file.read(entry)
              expect(content.length).to eq(1_000_000)
              expect(content[0]).to eq(("A".ord + index).chr)
            end
          end
        end
      end
    end

    context "with empty document" do
      it "handles empty string" do
        documents = [""]
        result = action.call(documents)

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            expect(zip_file.entries.length).to eq(1)

            content = zip_file.read(zip_file.entries.first)
            expect(content).to eq("")
          end
        end
      end
    end

    context "with empty array" do
      it "creates empty zip" do
        documents = []
        result = action.call(documents)

        expect(result).to be_a(String)
        expect(result[0..1]).to eq("PK")

        Tempfile.create(["test_", ".zip"]) do |temp_file|
          temp_file.write(result)
          temp_file.rewind

          Zip::File.open(temp_file.path) do |zip_file|
            expect(zip_file.entries).to be_empty
          end
        end
      end
    end
  end
end
