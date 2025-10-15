# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Validator do
  describe ".validate" do
    let(:min_rule) { KSEF::Validator::Rules::String::MinRule.new(5) }
    let(:max_rule) { KSEF::Validator::Rules::String::MaxRule.new(100) }

    context "with valid values" do
      it "validates single value against rule" do
        expect { described_class.validate("Hello World", min_rule) }.not_to raise_error
      end

      it "validates hash of values against rules" do
        values = { name: "John Doe", email: "test@example.com" }
        rules = {
          name: min_rule,
          email: KSEF::Validator::Rules::String::EmailRule.new
        }

        expect { described_class.validate(values, rules) }.not_to raise_error
      end

      it "validates array of values" do
        values = %w[Hello World Testing]
        expect { described_class.validate(values, min_rule) }.not_to raise_error
      end
    end

    context "with invalid values" do
      it "raises error for invalid single value" do
        expect { described_class.validate("Hi", min_rule) }.to raise_error(ArgumentError)
      end

      it "raises error for invalid value in hash" do
        values = { name: "Jo" } # Too short
        rules = { name: min_rule }

        expect { described_class.validate(values, rules) }.to raise_error(ArgumentError)
      end
    end

    context "with nil values" do
      it "skips nil values in hash" do
        values = { name: nil, email: "test@example.com" }
        rules = {
          name: min_rule,
          email: KSEF::Validator::Rules::String::EmailRule.new
        }

        expect { described_class.validate(values, rules) }.not_to raise_error
      end

      it "skips nil values in array" do
        values = ["Hello", nil, "World"]
        expect { described_class.validate(values, min_rule) }.not_to raise_error
      end
    end
  end
end
