# frozen_string_literal: true

module KSEF
  module Actions
    # Action for splitting large documents into smaller parts
    class SplitDocumentIntoParts
      # Split document into parts
      # @param document [String] Document to split
      # @param part_size [Integer] Maximum size of each part in bytes
      # @return [Array<String>] Array of document parts
      def call(document, part_size:)
        document_length = document.bytesize
        part_count = (document_length.to_f / part_size).ceil
        actual_part_size = (document_length.to_f / part_count).ceil

        parts = []

        part_count.times do |i|
          start = i * actual_part_size
          size = [actual_part_size, document_length - start].min

          break if size <= 0

          parts << document.byteslice(start, size)
        end

        parts
      end
    end
  end
end
