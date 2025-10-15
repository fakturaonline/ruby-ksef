# frozen_string_literal: true

require 'zip'

module KSEF
  module Actions
    # Action for compressing multiple documents into a ZIP archive
    class ZipDocuments
      # Compress documents into ZIP
      # @param documents [Array<String>] Array of document strings
      # @return [String] ZIP archive as binary string
      def call(documents)
        require 'tempfile'

        Tempfile.create(['zip_', '.zip']) do |temp_file|
          Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
            documents.each_with_index do |document, index|
              file_name = "xml_#{SecureRandom.hex(8)}.xml"
              zipfile.get_output_stream(file_name) { |f| f.write(document) }
            end
          end

          temp_file.rewind
          temp_file.read
        end
      end
    end
  end
end
