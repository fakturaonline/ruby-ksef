# frozen_string_literal: true

module KSEF
  module InvoiceSchema
    # Naglowek faktury (header)
    class Naglowek < BaseDTO
      include XMLSerializable

      attr_reader :wariant_formularza, :data_wytworzenia_fa, :system_info

      # @param wariant_formularza [ValueObjects::FormCode] Wariant formularza (default: FA(2))
      # @param data_wytworzenia_fa [Time, String] Data wytworzenia faktury (default: now)
      # @param system_info [String, nil] Nazwa systemu teleinformatycznego
      def initialize(
        wariant_formularza: ValueObjects::FormCode.new,
        data_wytworzenia_fa: Time.now,
        system_info: nil
      )
        @wariant_formularza = wariant_formularza
        @data_wytworzenia_fa = data_wytworzenia_fa.is_a?(String) ? Time.parse(data_wytworzenia_fa) : data_wytworzenia_fa
        @system_info = system_info
      end

      def to_rexml
        doc = REXML::Document.new
        naglowek = doc.add_element("Naglowek")

        # KodFormularza
        kod_formularza = naglowek.add_element("KodFormularza")
        kod_formularza.add_attribute("kodSystemowy", @wariant_formularza.to_s)
        kod_formularza.add_attribute("wersjaSchemy", @wariant_formularza.schema_version)
        kod_formularza.text = "FA"

        # WariantFormularza
        wariant = naglowek.add_element("WariantFormularza")
        wariant.text = @wariant_formularza.wariant_formularza.to_s

        # DataWytworzeniaFa
        data = naglowek.add_element("DataWytworzeniaFa")
        data.text = @data_wytworzenia_fa.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

        # SystemInfo (optional)
        if @system_info
          system = naglowek.add_element("SystemInfo")
          system.text = @system_info
        end

        doc
      end

      def self.from_nokogiri(element)
        kod_formularza = element.at_xpath("KodFormularza")
        kod_systemowy = kod_formularza&.attribute("kodSystemowy")&.value
        wariant_text = text_at(element, "WariantFormularza")
        wariant = wariant_text ? wariant_text.to_i : 2

        new(
          wariant_formularza: ValueObjects::FormCode.new(wariant),
          data_wytworzenia_fa: time_at(element, "DataWytworzeniaFa"),
          system_info: text_at(element, "SystemInfo")
        )
      end
    end
  end
end
