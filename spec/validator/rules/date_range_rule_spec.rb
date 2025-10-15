# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Validator::Rules::Date::AfterRule do
  describe "#call" do
    let(:rule) { described_class.new(Date.new(2020, 1, 1)) }

    it "validates date after threshold" do
      expect { rule.call(Date.new(2021, 1, 1)) }.not_to raise_error
    end

    it "raises error for date before threshold" do
      expect { rule.call(Date.new(2019, 1, 1)) }.to raise_error(ArgumentError)
    end

    it "raises error for equal date" do
      expect { rule.call(Date.new(2020, 1, 1)) }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe KSEF::Validator::Rules::Date::BeforeRule do
  describe "#call" do
    let(:rule) { described_class.new(Date.new(2025, 12, 31)) }

    it "validates date before threshold" do
      expect { rule.call(Date.new(2024, 1, 1)) }.not_to raise_error
    end

    it "raises error for date after threshold" do
      expect { rule.call(Date.new(2026, 1, 1)) }.to raise_error(ArgumentError)
    end

    it "raises error for equal date" do
      expect { rule.call(Date.new(2025, 12, 31)) }.to raise_error(ArgumentError)
    end
  end
end
