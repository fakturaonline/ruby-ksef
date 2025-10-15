# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    module DTOs
      # Stopka - zápatí faktury
      class Stopka < BaseDTO
        include XMLSerializable

        attr_reader :informacje

        # @param informacje [Array<String>, String, nil] Informace v zápatí (max 3)
        def initialize(informacje: nil)
          @informacje = if informacje.is_a?(Array)
                          informacje.compact.first(3)
                        elsif informacje
                          [informacje]
                        else
                          []
                        end
        end

        def to_rexml
          doc = REXML::Document.new
          stopka = doc.add_element('Stopka')

          @informacje.each do |info|
            info_elem = stopka.add_element('Informacje')
            info_elem.add_element('StInformacje').text = info.to_s
          end

          doc
        end
      end
    end
  end
end
