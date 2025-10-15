# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Validator::Rules::Number::MinRule do
  describe "#call" do
    let(:rule) { described_class.new(0.01) }

    it "validates positive amounts" do
      expect { rule.call(100.00) }.not_to raise_error
      expect { rule.call(BigDecimal("1000.50")) }.not_to raise_error
    end

    it "validates minimum amount" do
      expect { rule.call(0.01) }.not_to raise_error
    end

    it "raises error for zero" do
      expect { rule.call(0) }.to raise_error(ArgumentError)
    end

    it "raises error for negative amounts" do
      expect { rule.call(-100) }.to raise_error(ArgumentError)
    end

    it "validates BigDecimal amounts" do
      expect { rule.call(BigDecimal("1234.56")) }.not_to raise_error
    end
  end
end

RSpec.describe KSEF::Validator::Rules::Number::MaxRule do
  describe "#call" do
    let(:rule) { described_class.new(1000) }

    it "validates amounts below max" do
      expect { rule.call(500) }.not_to raise_error
    end

    it "validates max amount" do
      expect { rule.call(1000) }.not_to raise_error
    end

    it "raises error for amounts above max" do
      expect { rule.call(1001) }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe KSEF::Validator::Rules::Number::DecimalRule do
  describe "#call" do
    let(:rule) { described_class.new(max_digits: 5, max_decimals: 2) }

    it "validates decimal with correct precision" do
      expect { rule.call(123.45) }.not_to raise_error
    end

    it "validates integer as decimal" do
      expect { rule.call(100) }.not_to raise_error
    end

    it "validates decimal with fewer digits" do
      expect { rule.call(123.4) }.not_to raise_error
    end

    it "validates string decimal" do
      expect { rule.call("123.45") }.not_to raise_error
    end

    it "raises error for too many decimal places" do
      expect { rule.call(123.456) }.to raise_error(ArgumentError)
    end

    it "raises error for too many total digits" do
      expect { rule.call(123_456.78) }.to raise_error(ArgumentError)
    end
  end
end
