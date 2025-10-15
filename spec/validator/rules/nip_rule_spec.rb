# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Validator::Rules::Number::NipRule do
  let(:rule) { described_class.new }

  describe "#call" do
    it "validates correct NIP with valid checksum" do
      # Valid NIP: 5260001246
      expect { rule.call("5260001246") }.not_to raise_error
    end

    it "raises error for NIP with invalid checksum" do
      expect { rule.call("1234567890") }.to raise_error(ArgumentError, /checksum/)
    end

    it "raises error for NIP with wrong length" do
      expect { rule.call("123") }.to raise_error(ArgumentError, /format/)
      expect { rule.call("12345678901") }.to raise_error(ArgumentError, /format/)
    end

    it "raises error for NIP with non-digit characters" do
      expect { rule.call("123456789a") }.to raise_error(ArgumentError, /format/)
    end

    it "raises error for empty string" do
      expect { rule.call("") }.to raise_error(ArgumentError)
    end
  end
end
