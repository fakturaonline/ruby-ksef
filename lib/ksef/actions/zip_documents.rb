# frozen_string_literal: true

require "zip"

module KSEF
  module Actions
    # Action for compressing multiple documents into a ZIP archive
    class ZipDocuments
      # Compress documents into ZIP
      # @param documents [Array<String>] Array of document strings
      # @return [String] ZIP archive as binary string
      def call(documents)
        require "tempfile"
        require "securerandom"

        Tempfile.create(["zip_", ".zip"], binmode: true) do |temp_file|
          temp_file.close # Close before zip operations

          Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
            documents.each_with_index do |document, _index|
              file_name = "xml_#{SecureRandom.hex(8)}.xml"
              zipfile.get_output_stream(file_name) { |f| f.write(document) }
            end
          end

          File.binread(temp_file.path)
        end
      end
    end
  end
end
